import fitz  
from gtts import gTTS  
import os
import playsound  

def extract_text_from_pdf(pdf_path):
    """Extracts text from a PDF file and returns it as a string."""
    text = ""
    try:
        print("Current Working Directory:", os.getcwd())

        
        doc = fitz.open(pdf_path)

        
        for page in doc:
            text += page.get_text("text") + "\n"

        return text.strip()  
    except Exception as e:
        print("Error reading PDF:", e)
        return None

def text_to_speech(text, output_audio="output.mp3"):
    """Converts text to speech and saves it as an MP3 file using gTTS."""
    try:
        print("Converting text to speech...")

        # Convert text to speech
        tts = gTTS(text, lang="fr-ca")

        # Save as an audio file
        tts.save(output_audio)
        print(f"Audio saved as {output_audio}")

       
        playsound.playsound(output_audio)

    except Exception as e:
        print("Error in text-to-speech:", e)


pdf_file = "TP1Prolog.pdf" 
text_content = extract_text_from_pdf(pdf_file)

if text_content:
    print("Extracted Text:\n", text_content[:500]) 
    text_to_speech(text_content, "output.mp3")
