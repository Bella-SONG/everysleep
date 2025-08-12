#!/usr/bin/env python3
"""
썸네일 이미지 생성 스크립트
원본 이미지를 150x150 크기의 썸네일로 변환
"""

from PIL import Image
import os
import sys

# 경로 설정
source_dir = "/Users/jiwonsong/Downloads/이미지 파일"
output_dir = "/Users/jiwonsong/everysleep/thumbnails"

# 썸네일 크기
THUMBNAIL_SIZE = (150, 150)

def create_thumbnail(source_path, output_path):
    """이미지를 썸네일로 변환"""
    try:
        with Image.open(source_path) as img:
            # RGBA를 RGB로 변환 (JPEG는 알파 채널 지원 안함)
            if img.mode in ('RGBA', 'LA'):
                rgb_img = Image.new('RGB', img.size, (255, 255, 255))
                rgb_img.paste(img, mask=img.split()[-1] if img.mode == 'RGBA' else None)
                img = rgb_img
            
            # 정사각형으로 크롭 (중앙 기준)
            width, height = img.size
            size = min(width, height)
            left = (width - size) // 2
            top = (height - size) // 2
            right = left + size
            bottom = top + size
            
            img_cropped = img.crop((left, top, right, bottom))
            
            # 썸네일 크기로 리사이즈
            img_cropped.thumbnail(THUMBNAIL_SIZE, Image.Resampling.LANCZOS)
            
            # 저장 (JPEG 품질 85)
            img_cropped.save(output_path, 'JPEG', quality=85, optimize=True)
            return True
    except Exception as e:
        print(f"❌ 오류: {source_path} - {e}")
        return False

def main():
    # 출력 디렉토리 생성
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
        print(f"✅ 썸네일 폴더 생성: {output_dir}")
    
    # 이미지 파일 목록
    image_files = [f for f in os.listdir(source_dir) if f.endswith('.jpg')]
    
    print(f"🖼️  {len(image_files)}개의 이미지 파일 발견")
    print("=" * 60)
    
    success_count = 0
    for filename in image_files:
        source_path = os.path.join(source_dir, filename)
        
        # 파일명 정리 (모두 소문자로)
        output_filename = filename.lower()
        
        # S30_following_hope.jpg 파일명 수정
        if output_filename == "s30_following_hope.jpg":
            output_filename = "s030_following_hope.jpg"
        
        # S006_soothing_heart..jpg 파일명 수정
        if output_filename == "s006_soothing_heart..jpg":
            output_filename = "s006_soothing_heart.jpg"
            
        # S009, S010 파일명 수정 (서로 바뀜)
        if output_filename == "s009_heart_summer_asmr.jpg":
            output_filename = "s010_heart_summer_asmr.jpg"
        elif output_filename == "s010_heart_summer.jpg":
            output_filename = "s009_heart_summer.jpg"
        
        output_path = os.path.join(output_dir, output_filename)
        
        if create_thumbnail(source_path, output_path):
            success_count += 1
            print(f"✅ {filename} → {output_filename} (150x150)")
        else:
            print(f"❌ {filename} 변환 실패")
    
    print("=" * 60)
    print(f"📊 완료: {success_count}/{len(image_files)} 파일 변환 성공")
    print(f"📁 썸네일 저장 위치: {output_dir}")
    
    # Supabase 업로드 명령 출력
    print("\n📤 Supabase Storage 업로드 명령:")
    print("썸네일 폴더를 everysleeptrack 버킷의 thumbnails/ 폴더에 업로드하세요")

if __name__ == "__main__":
    # Pillow 설치 확인
    try:
        import PIL
    except ImportError:
        print("❌ Pillow 라이브러리가 설치되지 않았습니다.")
        print("설치 명령: pip install Pillow")
        sys.exit(1)
    
    main()