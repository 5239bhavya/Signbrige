from fastapi import FastAPI, File, UploadFile, Request, Form
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
import numpy as np
import cv2
import uvicorn
import math
import os
import string
import base64
import collections
import speech_recognition as sr
import mediapipe as mp

app = FastAPI(title="SignBridge Self-Contained Word AI Backend")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
ISL_GIFS_DIR = os.path.join(BASE_DIR, "ISL_Gifs")
LETTERS_DIR = os.path.join(BASE_DIR, "letters")
MODEL_PATH = os.path.join(BASE_DIR, "Model", "keras_model.h5")
LABELS_PATH = os.path.join(BASE_DIR, "Model", "labels.txt")

if os.path.exists(ISL_GIFS_DIR):
    app.mount("/ISL_Gifs", StaticFiles(directory=ISL_GIFS_DIR), name="ISL_Gifs")
if os.path.exists(LETTERS_DIR):
    app.mount("/letters", StaticFiles(directory=LETTERS_DIR), name="letters")

# MediaPipe 3D Landmark Detector
mp_hands = mp.solutions.hands
hands_detector_mp = mp_hands.Hands(
    static_image_mode=False,
    max_num_hands=2,
    min_detection_confidence=0.6,
    min_tracking_confidence=0.5
)

landmark_history = collections.deque(maxlen=15)

# Rich Synonym Mapping to ISL GIFs
SYNONYM_MAP = {
    "hi": "hello.gif",
    "hello": "hello.gif",
    "hey": "hello.gif",
    "greetings": "hello.gif",
    "thank you": "hello.gif",
    "thank": "hello.gif",
    "thanks": "hello.gif",
    "good morning": "good morning.gif",
    "morning": "good morning.gif",
    "good afternoon": "good afternoon.gif",
    "how are you": "are you busy.gif",
    "fine": "i am fine.gif",
    "i am fine": "i am fine.gif",
    "sorry": "i am sorry.gif",
    "i am sorry": "i am sorry.gif",
    "tired": "i am tired.gif",
    "what is your name": "what is your name.gif",
    "name": "what is your name.gif",
    "where is the bathroom": "where is the bathroom.gif",
    "bathroom": "where is the bathroom.gif",
    "toilet": "where is the bathroom.gif",
    "whats up": "whats up.gif",
    "what's up": "whats up.gif",
    "nice to meet you": "nice to meet you.gif",
    "help": "shall I help you.gif",
    "help me": "shall I help you.gif",
    "take care": "take care.gif",
    "stand up": "stand up.gif",
    "sit down": "sit down.gif",
    "be careful": "be careful.gif",
    "dont worry": "dont worry.gif",
    "don't worry": "dont worry.gif",
}

def classify_comprehensive_gesture(landmarks_list, landmark_history_seq):
    if not landmarks_list or len(landmarks_list) < 21:
        return None

    wrist = landmarks_list[0]
    thumb_tip = landmarks_list[4]
    thumb_ip = landmarks_list[3]

    index_tip = landmarks_list[8]
    index_pip = landmarks_list[6]
    index_mcp = landmarks_list[5]

    middle_tip = landmarks_list[12]
    middle_pip = landmarks_list[10]

    ring_tip = landmarks_list[16]
    ring_pip = landmarks_list[14]

    pinky_tip = landmarks_list[20]
    pinky_pip = landmarks_list[18]

    hand_y = wrist.y

    index_ext = index_tip.y < index_pip.y
    middle_ext = middle_tip.y < middle_pip.y
    ring_ext = ring_tip.y < ring_pip.y
    pinky_ext = pinky_tip.y < pinky_pip.y
    thumb_ext = math.hypot(thumb_tip.x - index_mcp.x, thumb_tip.y - index_mcp.y) > 0.12

    t_index_dist = math.hypot(thumb_tip.x - index_tip.x, thumb_tip.y - index_tip.y)
    t_middle_dist = math.hypot(thumb_tip.x - middle_tip.x, thumb_tip.y - middle_tip.y)

    thumb_up = thumb_tip.y < thumb_ip.y and thumb_tip.y < index_mcp.y
    thumb_down = thumb_tip.y > thumb_ip.y and thumb_tip.y > index_mcp.y

    if hand_y < 0.30:
        if index_ext and not middle_ext and not ring_ext and not pinky_ext:
            return "Learn"
        if index_ext and pinky_ext and not middle_ext and not ring_ext:
            return "Why"

    if 0.30 <= hand_y < 0.48:
        if t_index_dist < 0.07 and t_middle_dist < 0.08 and not index_ext:
            return "Food"
        if index_ext and middle_ext and ring_ext and not pinky_ext:
            return "Water"
        if index_ext and not middle_ext and not ring_ext:
            return "Who"

    if 0.48 <= hand_y < 0.78:
        if pinky_ext and thumb_ext and not index_ext and not middle_ext and not ring_ext:
            return "Call Me"

    if index_ext and pinky_ext and not middle_ext and not ring_ext and thumb_ext:
        return "I Love You"

    if index_ext and middle_ext and not ring_ext and not pinky_ext:
        return "Victory"

    if t_index_dist < 0.08 and middle_ext and ring_ext and pinky_ext:
        return "Okay"

    if thumb_up and not index_ext and not middle_ext and not ring_ext and not pinky_ext:
        return "Yes"

    if thumb_down and not index_ext and not middle_ext and not ring_ext and not pinky_ext:
        return "No"

    if index_ext and pinky_ext and not middle_ext and not ring_ext:
        return "Cool"

    if index_ext and not middle_ext and not ring_ext and not pinky_ext:
        return "Point"

    if len(landmark_history_seq) >= 5:
        first_frame = landmark_history_seq[0]
        last_frame = landmark_history_seq[-1]

        total_move = math.hypot(last_frame[0].x - first_frame[0].x, last_frame[0].y - first_frame[0].y)
        dy = last_frame[0].y - first_frame[0].y
        dx = last_frame[0].x - first_frame[0].x

        if index_ext and middle_ext and ring_ext and pinky_ext:
            if total_move > 0.18 and abs(dx) > 0.1:
                return "Hello"
            if total_move > 0.18 and dy > 0.12:
                return "Thank You"
            if total_move > 0.18 and dy < -0.12:
                return "Good Morning"
            if total_move < 0.08:
                return "Stop"

    return None

def predict_sign_image(img: np.ndarray) -> dict:
    if img is None or img.size == 0:
        return {"label": "", "type": "none", "status": "invalid_image"}

    try:
        img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        mp_results = hands_detector_mp.process(img_rgb)

        if mp_results.multi_hand_landmarks:
            primary_hand = mp_results.multi_hand_landmarks[0]
            landmarks_list = primary_hand.landmark
            landmark_history.append(landmarks_list)

            detected_sign = classify_comprehensive_gesture(landmarks_list, list(landmark_history))
            if detected_sign:
                return {"label": detected_sign, "type": "word", "status": "success"}
            else:
                return {"label": "", "type": "none", "status": "analyzing_gesture"}

        landmark_history.clear()
        return {"label": "", "type": "none", "status": "no_hand"}

    except Exception as e:
        print(f"Prediction exception: {e}")
        return {"label": "", "type": "none", "status": str(e)}

def find_isl_gif_or_letter(clean_text: str):
    for c in string.punctuation:
        clean_text = clean_text.replace(c, "")
    clean_text = clean_text.strip().lower()

    # 1. Direct Synonym Check
    if clean_text in SYNONYM_MAP:
        mapped_gif = SYNONYM_MAP[clean_text]
        if os.path.exists(os.path.join(ISL_GIFS_DIR, mapped_gif)):
            return {
                "status": "gif",
                "path": f"ISL_Gifs/{mapped_gif}",
                "message": "GIF mapped",
                "recognized_text": clean_text
            }

    # 2. Exact Filename Check
    gif_file = f"{clean_text}.gif"
    gif_path = os.path.join(ISL_GIFS_DIR, gif_file)
    if os.path.exists(gif_path):
        return {
            "status": "gif",
            "path": f"ISL_Gifs/{gif_file}",
            "message": "GIF found",
            "recognized_text": clean_text
        }

    # 3. Substring / Word Match in ISL_GIFS
    words = clean_text.split()
    for w in words:
        if w in SYNONYM_MAP and os.path.exists(os.path.join(ISL_GIFS_DIR, SYNONYM_MAP[w])):
            return {
                "status": "gif",
                "path": f"ISL_Gifs/{SYNONYM_MAP[w]}",
                "message": "Word GIF mapped",
                "recognized_text": clean_text
            }

        w_gif = f"{w}.gif"
        if os.path.exists(os.path.join(ISL_GIFS_DIR, w_gif)):
            return {
                "status": "gif",
                "path": f"ISL_Gifs/{w_gif}",
                "message": "Word GIF found",
                "recognized_text": clean_text
            }

    # Default to Hello GIF animation
    return {
        "status": "gif",
        "path": "ISL_Gifs/hello.gif",
        "message": "Default sign animation",
        "recognized_text": clean_text
    }

# ── API ENDPOINTS ──────────────────────────────────────────────────────────────

@app.get("/")
@app.get("/health")
def health_check():
    return {"status": "ok", "service": "SignBridge Self-Contained Word AI Backend"}

@app.post("/predict-letter/")
async def predict_letter(file: UploadFile = File(...)):
    try:
        contents = await file.read()
        nparr = np.frombuffer(contents, np.uint8)
        img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

        result = predict_sign_image(img)
        return {
            "predicted_letter": result.get("label", ""),
            "label": result.get("label", ""),
            "type": result.get("type", "word"),
            "status": result.get("status", "")
        }
    except Exception as e:
        return JSONResponse(status_code=500, content={"error": str(e)})

@app.post("/predict")
async def predict_base64(request: Request):
    try:
        data = await request.json()
        img_data = data.get('image', '')
        if "," in img_data:
            img_data = img_data.split(",")[1]

        nparr = np.frombuffer(base64.b64decode(img_data), np.uint8)
        img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

        result = predict_sign_image(img)
        return {
            "predicted_letter": result.get("label", ""),
            "label": result.get("label", ""),
            "type": result.get("type", "word"),
            "status": result.get("status", "")
        }
    except Exception as e:
        return JSONResponse(status_code=500, content={"error": str(e)})

@app.post("/text-to-isl/")
async def text_to_isl(request: Request, text: str = Form(None)):
    try:
        input_text = text
        if not input_text:
            body_data = await request.json()
            input_text = body_data.get('text', '')

        if not input_text:
            return JSONResponse(status_code=400, content={"message": "No text provided"})

        result = find_isl_gif_or_letter(input_text)
        return result
    except Exception as e:
        return JSONResponse(status_code=500, content={"message": f"Server error: {e}"})

@app.post("/voice-to-isl/")
async def voice_to_isl(file: UploadFile = File(...)):
    try:
        temp_audio = os.path.join(BASE_DIR, "temp_voice.wav")
        contents = await file.read()
        with open(temp_audio, "wb") as f:
            f.write(contents)

        recognizer = sr.Recognizer()
        with sr.AudioFile(temp_audio) as source:
            audio_data = recognizer.record(source)
            recognized_text = recognizer.recognize_google(audio_data)

        if os.path.exists(temp_audio):
            os.remove(temp_audio)

        result = find_isl_gif_or_letter(recognized_text)
        return result
    except sr.UnknownValueError:
        return JSONResponse(status_code=400, content={"message": "Speech could not be understood"})
    except Exception as e:
        return JSONResponse(status_code=500, content={"message": f"Server error: {e}"})

if __name__ == "__main__":
    print("🚀 Starting SignBridge Self-Contained Backend Server on port 5000...")
    uvicorn.run(app, host="0.0.0.0", port=5000)
