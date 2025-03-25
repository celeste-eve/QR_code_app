import qrcode
from reportlab.lib.pagesizes import inch
from reportlab.pdfgen import canvas
from reportlab.lib.utils import ImageReader
import io
import argparse
import os
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def create_qr_code(data):
    qr = qrcode.QRCode(
        version=1,
        error_correction=qrcode.constants.ERROR_CORRECT_L,
        box_size=10,
        border=4,
    )
    qr.add_data(data)
    qr.make(fit=True)
    img = qr.make_image(fill_color="black", back_color="white")
    
    img_byte_arr = io.BytesIO()
    img.save(img_byte_arr, format='PNG')
    img_byte_arr.seek(0)
    return img_byte_arr

def save_single_qr(data, output_path):
    """Generate a single QR code and save it as PNG"""
    qr = qrcode.QRCode(
        version=1,
        error_correction=qrcode.constants.ERROR_CORRECT_L,
        box_size=10,
        border=4,
    )
    qr.add_data(data)
    qr.make(fit=True)
    img = qr.make_image(fill_color="black", back_color="white")
    img.save(output_path)
    return output_path

def add_qr_to_pdf(strings, filename):
    # Validate input
    if not strings:
        logger.error("No data provided for QR codes")
        return None
        
    logger.info(f"Starting to generate PDF with {len(strings)} QR codes")
    
    c = canvas.Canvas(filename, pagesize=(4*inch, 2*inch))
    font_size = 16
    
    # Process each string with progress logging
    for i, s in enumerate(strings, 1):
        try:
            logger.info(f"Processing QR code {i} of {len(strings)}")
            c.setFont("Helvetica-Bold", font_size)
            qr_stream = create_qr_code(s)
            img_reader = ImageReader(qr_stream)
            
            c.drawImage(img_reader, 0, 0, width=2*inch, height=2*inch)
            
            if "PLT " in s:
                parts = s.split("PLT ")
                first_line = parts[0].strip()
                second_line = "PLT " + parts[1].strip()
                x_position = 2.1*inch
                c.drawString(x_position, 1.2*inch, first_line)
                c.drawString(x_position, 0.8*inch, second_line)
            else:
                x_position = 2.1*inch
                c.drawString(x_position, 1.0*inch, s)
                
            c.showPage()
        except Exception as e:
            logger.error(f"Error processing QR code {i}: {str(e)}")
            continue
    
    try:
        c.save()
        logger.info("PDF generation completed successfully")
    except Exception as e:
        logger.error(f"Error saving PDF: {str(e)}")
        raise

def create_single_qr_pdf(data, output_path):
    """Generate a PDF with a single QR code and its text"""
    add_qr_to_pdf([data], output_path)
    return output_path

def create_multiple_qr_pdf(data_string, output_path):
    """Generate a PDF with multiple QR codes from comma-separated locations"""
    # Debug logging for input
    logger.info(f"Received data string: '{data_string}'")
    
    if not data_string or data_string.isspace():
        logger.error("Empty or whitespace-only data string received")
        raise ValueError("Please add at least one location")
    
    # Handle different types of comma separations and clean the input
    # Replace any combination of comma and space with a single comma
    cleaned_string = data_string.replace(' ,', ',').replace(', ', ',').replace(' , ', ',')
    
    # Split and clean the input string, filtering out empty or whitespace entries
    locations = [loc.strip() for loc in cleaned_string.split(',')]
    locations = [loc for loc in locations if loc]  # Remove empty strings
    
    logger.info(f"Parsed locations: {locations}")
    logger.info(f"Number of locations: {len(locations)}")
    
    if not locations:
        logger.error("No valid locations after parsing")
        raise ValueError("Please add at least one valid location")
    
    # Rest of the function
    try:
        # Ensure output directory exists
        output_dir = os.path.dirname(output_path)
        if output_dir and not os.path.exists(output_dir):
            os.makedirs(output_dir)
            
        add_qr_to_pdf(locations, output_path)
        logger.info(f"Successfully created PDF at {output_path}")
        return output_path
    except Exception as e:
        logger.error(f"Error creating PDF: {str(e)}")
        backup_path = os.path.join(os.path.dirname(__file__), f"backup_{os.path.basename(output_path)}")
        logger.info(f"Attempting to save to backup location: {backup_path}")
        add_qr_to_pdf(locations, backup_path)
        return backup_path

def generate_qr_codes(data_list, output_path):
    pdf = FPDF()
    pdf.set_auto_page_break(auto=True, margin=15)
    pdf.add_page()
    pdf.set_font("Arial", size=12)

    x, y = 10, 10  # Starting position for QR codes
    qr_size = 40   # Size of each QR code

    for data in data_list:
        # Generate QR code
        qr = qrcode.QRCode(box_size=10, border=2)
        qr.add_data(data)
        qr.make(fit=True)
        qr_img = qr.make_image(fill="black", back_color="white")
        qr_img_path = f"temp_{data}.png"
        qr_img.save(qr_img_path)

        # Add QR code to PDF
        pdf.image(qr_img_path, x=x, y=y, w=qr_size, h=qr_size)
        pdf.set_xy(x, y + qr_size + 2)
        pdf.cell(w=qr_size, h=10, txt=data, border=0, ln=1, align='C')

        # Update position for the next QR code
        x += qr_size + 10
        if x + qr_size > 190:  # Move to the next row if exceeding page width
            x = 10
            y += qr_size + 20
            if y + qr_size > 270:  # Add a new page if exceeding page height
                pdf.add_page()
                y = 10

    # Save the PDF
    pdf.output(output_path)
    print(f"PDF saved at {output_path}")

if __name__ == "__main__":
    try:
        parser = argparse.ArgumentParser(description='Generate QR Code or PDF')
        parser.add_argument('--data', help='Data to encode in QR code(s). For multiple locations, separate with commas')
        parser.add_argument('--output', help='Output file path')
        parser.add_argument('--mode', default='single', choices=['single', 'pdf', 'single_pdf', 'multiple_pdf'], 
                          help='Mode: single QR code, PDF with multiple codes, PDF with single code, or PDF with multiple locations')
        
        args = parser.parse_args()
        logger.info(f"Received args: mode={args.mode}, data='{args.data}', output='{args.output}'")
        
        if not args.data:
            raise ValueError("No data provided")
            
        if args.mode == 'single' and args.data and args.output:
            # Generate a single QR code image
            output_path = save_single_qr(args.data, args.output)
            print(output_path)  # Print the path so Flutter can capture it
        elif args.mode == 'single_pdf' and args.data and args.output:
            # Generate a PDF with a single QR code
            output_path = create_single_qr_pdf(args.data, args.output)
            print(output_path)  # Print the path so Flutter can capture it
        elif args.mode == 'multiple_pdf' and args.data and args.output:
            # Generate a PDF with multiple QR codes from comma-separated locations
            output_path = create_multiple_qr_pdf(args.data, args.output)
            print(output_path)  # Print the path so Flutter can capture it
        elif args.mode == 'pdf' and args.data and args.output:
            # Generate a PDF with multiple QR codes
            data_list = args.data.split(",")
            generate_qr_codes(data_list, args.output)
    except Exception as e:
        logger.error(f"Error in main: {str(e)}")
        print(f"Error: {str(e)}")
