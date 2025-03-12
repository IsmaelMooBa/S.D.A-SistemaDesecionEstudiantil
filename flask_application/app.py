from flask import Flask, request, jsonify
import pandas as pd

app = Flask(__name__)

@app.route('/upload', methods=['POST'])
def upload_file():
    if 'file' not in request.files:
        return 'No file part', 400
    
    file = request.files['file']
    
    if file.filename == '':
        return 'No selected file', 400

    try:
        df = pd.read_csv(file)
        return df.to_string(), 200
    except Exception as e:
        return f'Error al leer el archivo CSV: {str(e)}', 500

if __name__ == '__main__':
    app.run(debug=True)
