from flask import Flask, request, jsonify
import mercadopago
import os

# 🛑 NOTA: Lee la clave de forma segura del entorno de Cloud Run
MP_ACCESS_TOKEN = os.environ.get('MP_ACCESS_TOKEN')

# Inicializar Mercado Pago
if not MP_ACCESS_TOKEN:
    print("FATAL ERROR: MP_ACCESS_TOKEN no configurado.")
else:
    mercadopago.configure(access_token=MP_ACCESS_TOKEN)

app = Flask(__name__)

# 🚀 Endpoint que llama Flutter
@app.route('/iniciar-suscripcion', methods=['POST'])
def iniciar_suscripcion():
    if not MP_ACCESS_TOKEN:
        return jsonify({"error": "Error de configuración: Clave secreta de MP no definida."}), 500

    data = request.get_json()

    user_id = data.get('userId')
    plan_id = data.get('planId')
    plan_title = data.get('planTitle')

    if not user_id or not plan_id or not plan_title:
        return jsonify({"error": "Faltan parámetros de Flutter (userId, planId o planTitle)."}), 400

    try:
        # 🛑 REEMPLAZAR con la lógica REAL para buscar el email del usuario en Firebase.
        client_email = f"cliente_{user_id}@tusalon.com"

        subscription_data = {
            "reason": f"Suscripción al plan {plan_title}",
            "auto_recurring": {
                "frequency": 1,
                "frequency_type": "months",
                "transaction_amount": 99000 if plan_title == "Growth" else 60000,
                "currency_id": "COP",
                "plan_id": plan_id
            },
            "back_url": "https://tusalon.com/pago-exitoso",
            "external_reference": user_id,
            "payer_email": client_email,
        }

        mp_response = mercadopago.subscriptions.create(subscription_data)

        checkout_url = mp_response['response']['init_point']

        # DEVOLVER LA URL DE CHECKOUT A FLUTTER
        return jsonify({
            "success": True,
            "checkoutUrl": checkout_url
        }), 200

    except Exception as e:
        print(f"Error al procesar la suscripción: {e}")
        return jsonify({
            "error": 'Fallo al procesar la suscripción.',
            "details": str(e)
        }), 500

if __name__ == "__main__":
    port = int(os.environ.get('PORT', 8080))
    app.run(host='0.0.0.0', port=port)
