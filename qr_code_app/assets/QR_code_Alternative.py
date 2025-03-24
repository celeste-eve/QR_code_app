import qrcode
from reportlab.lib.pagesizes import inch
from reportlab.pdfgen import canvas
from reportlab.lib.utils import ImageReader
import io
import argparse

# same as OG
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


# same as OG
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


# same as OG    
def add_qr_to_pdf(strings, filename):
    c = canvas.Canvas(filename, pagesize=(4*inch, 2*inch))
    font_size = 16
    for s in strings:
        c.setFont("Helvetica-Bold", font_size)
        qr_stream = create_qr_code(s)
        img_reader = ImageReader(qr_stream)
        
        c.drawImage(img_reader, 0, 0, width=2*inch, height=2*inch)
        # splits text into 3 lines
        def format_text(s):
            """Splits the location string into three meaningful parts."""
            parts = s.split()

            if len(parts) > 6:
                first_line = f"{parts[0]} {parts[1]} {parts[2]}"  # Example: "C1 BAY"
                second_line = f"{parts[3]} {parts[4]}"  # Example: "1 SHELF"
                third_line = f"{parts[5]} {parts[6]}" if len(parts) > 6 else parts[5]  # Example: "3 PALLET A"

                # Set fixed x position at 2.1 inches (just after QR code)
                x_position = 2.1*inch
            
                # Draw both lines with fixed left alignment
                c.drawString(x_position, 1.5*inch, first_line)
                c.drawString(x_position, 1.0*inch, second_line)
                c.drawString(x_position, 0.5*inch, third_line)
            else:
                first_line = f"{parts[0]} {parts[1]} {parts[2]}"  # Example: "C1 BAY 1"
                second_line = f"{parts[3]}"  # Example: "SHELF"
                third_line = f"{parts[4]} {parts[5]}"  # Example: "PALLET A"
                
                # Set fixed x position at 2.1 inches (just after QR code)
                x_position = 2.1*inch
            
                # Draw both lines with fixed left alignment
                c.drawString(x_position, 1.5*inch, first_line)
                c.drawString(x_position, 1.0*inch, second_line)
                c.drawString(x_position, 0.5*inch, third_line)

        c.showPage()
    c.save()
        
  

def create_single_qr_pdf(data, output_path):
    """Generate a PDF with a single QR code and its text"""
    add_qr_to_pdf([data], output_path)
    return output_path


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Generate QR Code or PDF')
    parser.add_argument('--data', help='Data to encode in single QR code')
    parser.add_argument('--output', help='Output file path')
    parser.add_argument('--mode', default='single', choices=['single', 'pdf', 'single_pdf'], 
                      help='Mode: single QR code, PDF with multiple codes, or PDF with single code')
    
    args = parser.parse_args()
    
    if args.mode == 'single' and args.data and args.output:
        # Generate a single QR code image
        output_path = save_single_qr(args.data, args.output)
        print(output_path)  # Print the path so Flutter can capture it
    elif args.mode == 'single_pdf' and args.data and args.output:
        # Generate a PDF with a single QR code
        output_path = create_single_qr_pdf(args.data, args.output)
        print(output_path)  # Print the path so Flutter can capture it



def add_qr_to_pdf(strings, filename):
    c = canvas.Canvas(filename, pagesize=(4*inch, 2*inch))
    font_size = 16
    for s in strings:
        c.setFont("Helvetica-Bold", font_size)
        qr_stream = create_qr_code(s)
        img_reader = ImageReader(qr_stream)
        
        c.drawImage(img_reader, 0, 0, width=2*inch, height=2*inch)

