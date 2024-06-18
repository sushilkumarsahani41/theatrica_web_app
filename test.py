import firebase_admin
from firebase_admin import credentials, firestore, auth
import pandas as pd
import random

# Path to your Firebase Admin SDK key
cred_path = 'sarweb-service.json'

# Initialize the Firebase Admin SDK
cred = credentials.Certificate(cred_path)
firebase_admin.initialize_app(cred)

# Firestore client
db = firestore.client()

# Read user data from a CSV file, ensuring phone numbers are read as strings
users_df = pd.read_csv('usersheet.csv', dtype={'Phone': str})

# Default password for all users
default_password = 'Theatrica#2024!'

def format_phone_number(phone):
    if phone and not phone.startswith('+'):
        return '+91' + phone  # Prepend the US country code if no + sign is present
    return phone

def create_user_and_store_data(user_data):
    try:
        # Format the phone number correctly if it exists
        formatted_phone = format_phone_number(user_data['Phone']) if 'Phone' in user_data and user_data['Phone'] else None

        # Create user in Firebase Authentication
        user = auth.create_user(
            email=user_data['Email'],
            email_verified=False,  # Set to True if you handle email verification
            password=default_password,
            phone_number=formatted_phone  # Use the formatted phone number
        )
        print(f'Successfully created user: {user.uid}')

        # Generate a random three-digit ID
        random_id = random.randint(100, 999)

        # Add additional data in Firestore
        doc_ref = db.collection('users').document(user.uid)
        doc_ref.set({
            'name': user_data['Name'],
            'admin': False,
            'email': user_data['Email'],
            'phone': formatted_phone,
            'id': str(random_id)
        })
        print(f'Data stored in Firestore for user: {user.uid} with random ID: {random_id}')

    except Exception as e:
        print(f'Error creating user: {e}')

# Loop over each row in the DataFrame to create users
for index, user_row in users_df.iterrows():
    create_user_and_store_data(user_row)
