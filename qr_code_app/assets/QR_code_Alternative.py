from flask import Flask, request, jsonify, send_file
from flask_cors import CORS
import os
import logging
from io import BytesIO
from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import inch
import qrcode


# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)  # Enable CORS for cross-origin requests (useful for Flutter web apps)

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
    img_byte_arr = BytesIO()
    img.save(img_byte_arr, format='PNG')
    img_byte_arr.seek(0)
    return img_byte_arr

def add_qr_to_pdf(strings):
    if not strings:
        logger.error("No data provided for QR codes")
        return None

    logger.info(f"Starting to generate PDF with {len(strings)} QR codes")
    pdf_buffer = BytesIO()
    c = canvas.Canvas(pdf_buffer, pagesize=(4 * inch, 2 * inch))
    font_size = 16

    for s in strings:
        try:
            c.setFont("Helvetica-Bold", font_size)
            qr_stream = create_qr_code(s)
            img_reader = ImageReader(qr_stream)
            c.drawImage(img_reader, 0, 0, width=2 * inch, height=2 * inch)

            parts = s.split()
            if len(parts) > 6:
                first_line = f"{parts[0]} {parts[1]} {parts[2]}"
                second_line = f"{parts[3]} {parts[4]}"
                third_line = f"{parts[5]} {parts[6]}" if len(parts) > 6 else parts[5]
            else:
                first_line = f"{parts[0]} {parts[1]} {parts[2]}"
                second_line = f"{parts[3]}"
                third_line = f"{parts[4]} {parts[5]}"

            x_position = 2.1 * inch
            c.drawString(x_position, 1.5 * inch, first_line)
            c.drawString(x_position, 1.0 * inch, second_line)
            c.drawString(x_position, 0.5 * inch, third_line)
            c.showPage()
        except Exception as e:
            logger.error(f"Error processing QR code: {str(e)}")
            continue

    c.save()
    pdf_buffer.seek(0)
    return pdf_buffer

@app.route('/generate_qr_pdf', methods=['POST'])
def generate_qr_pdf():
    try:
        data = request.json
        qr_data = data.get('data')
        if not qr_data:
            return jsonify({'error': 'No data provided'}), 400

        locations = [loc.strip() for loc in qr_data.split(',') if loc.strip()]
        if not locations:
            return jsonify({'error': 'No valid locations provided'}), 400

        pdf_buffer = add_qr_to_pdf(locations)
        if not pdf_buffer:
            return jsonify({'error': 'Failed to generate PDF'}), 500

        return send_file(
            pdf_buffer,
            mimetype='application/pdf',
            as_attachment=True,
            download_name='Racking_QR_Codes.pdf'
        )
    except Exception as e:
        logger.error(f"Error generating QR PDF: {str(e)}")
        return jsonify({'error': str(e)}), 500

@app.route('/generate_multiple_qr_pdf', methods=['POST'])
def generate_multiple_qr_pdf_route():
    try:
        data_string = request.json.get('data')
        if not data_string:
            return jsonify({'error': 'No data provided'}), 400

        output_path = 'Racking_QR_Codes.pdf'
        create_multiple_qr_pdf(data_string, output_path)
        return send_file(output_path, as_attachment=True)
    except Exception as e:
        logger.error(f"Error generating multiple QR code PDF: {str(e)}")
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)