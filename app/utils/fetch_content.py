import requests
import io
from PIL import Image
from bs4 import BeautifulSoup

def fetch_url_content(url: str) -> dict:
    """
    Fetches both text and image content from a URL.
    Specially handles social media links like Instagram.
    """
    result = {
        "success": False,
        "text": None,
        "imageBuffer": None,
        "error": None
    }
    
    try:
        headers = {
            "User-Agent": "facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)",
            "Accept-Language": "en-US,en;q=0.9",
        }
        
        # Instagram specific handling
        if "instagram.com" in url:
            try:
                if "/p/" in url or "/reels/" in url:
                    base_url = url.split("?")[0]
                    if not base_url.endswith("/"):
                        base_url += "/"
                    media_url = base_url + "media/?size=l"
                    
                    print(f"📸 Attempting Instagram direct fetch: {media_url}")
                    media_resp = requests.get(media_url, timeout=10, headers=headers, allow_redirects=True)
                    
                    if media_resp.status_code == 200 and "image" in media_resp.headers.get("Content-Type", ""):
                        result["imageBuffer"] = media_resp.content
                        result["success"] = True
            except Exception as ig_err:
                print(f"⚠️ Instagram direct fetch failed: {str(ig_err)}")

        # General fetch if Instagram direct didn't get the image or for other URLs
        response = requests.get(url, timeout=10, headers=headers)
        response.raise_for_status()
        
        content_type = response.headers.get("Content-Type", "").lower()
        
        if "image" in content_type:
            # It's a direct image URL
            result["imageBuffer"] = response.content
            result["success"] = True
        else:
            # It's a web page, scrape for text and image
            soup = BeautifulSoup(response.content, 'html.parser')
            
            # Extract text (caption/title/description)
            og_title = soup.find("meta", property="og:title")
            og_description = soup.find("meta", property="og:description")
            twitter_description = soup.find("meta", attrs={"name": "twitter:description"})
            
            extracted_text = []
            if og_title and og_title.get("content"):
                extracted_text.append(og_title["content"])
            if og_description and og_description.get("content"):
                extracted_text.append(og_description["content"])
            elif twitter_description and twitter_description.get("content"):
                extracted_text.append(twitter_description["content"])
            
            if extracted_text:
                result["text"] = " | ".join(extracted_text)
                result["success"] = True
            
            # Extract image if we don't have one yet
            if not result["imageBuffer"]:
                og_image = soup.find("meta", property="og:image")
                if og_image and og_image.get("content"):
                    img_url = og_image["content"]
                    print(f"🔗 Found og:image: {img_url}")
                    img_resp = requests.get(img_url, timeout=10, headers=headers)
                    if img_resp.status_code == 200 and "image" in img_resp.headers.get("Content-Type", ""):
                        result["imageBuffer"] = img_resp.content
                        result["success"] = True

        # Verify image if present
        if result["imageBuffer"]:
            try:
                img = Image.open(io.BytesIO(result["imageBuffer"]))
                img.verify()
            except Exception as img_err:
                print(f"⚠️ Invalid image data: {str(img_err)}")
                result["imageBuffer"] = None
                if not result["text"]:
                    result["success"] = False
                    result["error"] = "Failed to extract valid content"

        if not result["success"]:
            result["error"] = "Could not extract text or image from URL"
            
    except Exception as e:
        result["error"] = str(e)
        print(f"❌ Error fetching URL content: {str(e)}")
        
    return result

def download_image(url: str) -> dict:
    """Compatibility wrapper for existing code"""
    res = fetch_url_content(url)
    if res["imageBuffer"]:
        return {"success": True, "buffer": res["imageBuffer"]}
    return {"success": False, "error": res["error"] or "No image found"}
