import requests

user_id = "25084876370"
url = f"https://i.instagram.com/api/v1/users/{user_id}/info/"

headers = {
    "User-Agent": "Instagram 155.0.0.37.107",
    "Accept": "*/*",
    "Accept-Language": "en-US",
}

try:
    r = requests.get(url, headers=headers)
    if r.status_code == 200:
        data = r.json()
        user = data.get("user", {})
        print("✅ Username:", user.get("username"))
        print("📛 Nome:", user.get("full_name"))
        print("🔗 Link:", f"https://instagram.com/{user.get('username')}")
        print("🔒 Conta privada?", user.get("is_private"))
        print("👤 Verificada?", user.get("is_verified"))
    else:
        print("❌ Erro:", r.status_code, r.text)
except Exception as e:
    print("⚠️ Exceção:", e)
