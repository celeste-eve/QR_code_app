from matplotlib import style
import qrcode
from reportlab.lib.pagesizes import inch
from reportlab.pdfgen import canvas
from reportlab.lib.utils import ImageReader
from reportlab.platypus import Paragraph 
from reportlab.lib.styles import getSampleStyleSheet
import io
import argparse
import os
import logging
from fpdf import FPDF

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

def create_single_qr_pdf(data, output_path):
    """Generate a PDF with a single QR code and its text"""
    add_qr_to_pdf([data], output_path)
    return output_path

def create_multiple_qr_pdf(data_string, output_path=None):
    """Generate a PDF with multiple QR codes from comma-separated locations"""
    logger.info(f"Received data string: '{data_string}'")
    if not data_string or data_string.isspace():
        raise ValueError("Please add at least one location")
    
    # Split the input string by commas and strip whitespace
    locations = [loc.strip() for loc in data_string.split(',') if loc.strip()]
    if not locations:
        raise ValueError("No valid locations provided")
    
    logger.info(f"Parsed locations: {locations}")
    
    # Use the first location to construct the file name if output_path is not provided
    if not output_path:
        sanitized_name = locations[0].replace(" ", "_").replace("/", "_")  # Replace spaces and slashes
        output_path = f"{sanitized_name}_QR_code.pdf"
        logger.info(f"Output path not provided. Using default: {output_path}")
    
    add_qr_to_pdf(locations, output_path)
    return output_path

def add_qr_to_pdf(strings, filename):
    """Generate a PDF with QR codes and optional text"""
    if not strings:
        raise ValueError("No data provided for QR codes")
    
    c = canvas.Canvas(filename, pagesize=(4 * inch, 2 * inch))
    font_size = 16

    for s in strings:
        try: 
            c.setFont("Helvetica-Bold", font_size)
            qr_stream = create_qr_code(s)
            img_reader = ImageReader(qr_stream)
        
            c.drawImage(img_reader, 0, 0, width=2*inch, height=2*inch)

            """Splits the location string into three meaningful parts."""
            parts = s.split()
            if len(parts) > 6:
                 # splits text into 3 lines
                """Splits the location string into three meaningful parts."""
                parts = s.split()

                first_line = f"{parts[0]} {parts[1]} {parts[2]}"  # Example: "C1 BAY"
                second_line = f"{parts[3]} {parts[4]}"  # Example: "1 SHELF"
                third_line = f"{parts[5]} {parts[6]}" if len(parts) > 6 else parts[5]  # Example: "3 PALLET A"

            else:
                # splits text into 3 lines
                """Splits the location string into three meaningful parts."""
                parts = s.split()
                first_line = f"{parts[0]} {parts[1]} {parts[2]}"  # Example: "C1 BAY 1"
                second_line = f"{parts[3]}"  # Example: "SHELF"
                third_line = f"{parts[4]} {parts[5]}"  # Example: "PALLET A"

            x_position = 1.8 * inch
            start_y = 1.5 * inch
            line_spacing = 0.2 * inch

            width_limit = 2.0 * inch  

            def draw_wrapped_line(text, x, y):
                para = Paragraph(text, style)
                para_width, para_height = para.wrap(width_limit, 2 * inch)
                para.drawOn(c, x, y - para_height)

            draw_wrapped_line(first_line, x_position, start_y)
            draw_wrapped_line(second_line, x_position, start_y - line_spacing)
            draw_wrapped_line(third_line, x_position, start_y - 2 * line_spacing)

            c.showPage()
        except Exception as e:
            logger.error(f"Error processing QR code: {str(e)}")
            continue

    c.save()

def generate_pallet_qr_pdf(data_string, output_path):
    """Generate a PDF specifically for pallet QR codes"""
    logger.info("Generating pallet QR codes...")
    create_multiple_qr_pdf(data_string, output_path)

def generate_racking_qr_pdf(data_string, output_path):
    """Generate a PDF specifically for racking beam QR codes"""
    logger.info("Generating racking beam QR codes...")
    create_multiple_qr_pdf(data_string, output_path)

if __name__ == "__main__":
    try:
        parser = argparse.ArgumentParser(description='Generate a PDF with multiple QR codes')
        parser.add_argument('--data', help='Data to encode in QR code(s). For multiple locations, separate with commas')
        parser.add_argument('--output', help='Output file path (optional)')
        
        args = parser.parse_args()
        logger.info(f"Received args: data='{args.data}', output='{args.output}'")
        
        if not args.data:
            raise ValueError("No data provided")
        
        # Generate the PDF with a dynamic or provided file name
        output_path = create_multiple_qr_pdf(args.data, args.output)
        print(output_path)  # Print the path so Flutter can capture it

    except Exception as e:
        logger.error(f"Error in main: {str(e)}")
        print(f"Error: {str(e)}")