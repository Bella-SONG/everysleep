#!/usr/bin/env python3
import pandas as pd
import re

def generate_proper_normalized_sql():
    # 엑셀 파일 읽기
    tracks_df = pd.read_excel('/Users/jiwonsong/Downloads/에브리슬립_음원리스트.xlsx')
    themes_df = pd.read_excel('/Users/jiwonsong/Downloads/에브리슬립_테마.xlsx')
    
    sql_statements = []
    sql_statements.append("-- 에브리슬립 정규화된 데이터 (데이터베이스 설계 원칙 적용)")
    sql_statements.append("-- Excel 데이터를 분석하여 정규화 및 가공")
    sql_statements.append("")
    
    # 1. 기분 데이터 정규화 (Excel에서 추출한 실제 기분들)
    sql_statements.append("-- ================================")
    sql_statements.append("-- 1. 기분(MOODS) 데이터 정규화")
    sql_statements.append("-- ================================")
    
    # Excel에서 실제 사용되는 기분들 추출
    all_moods = set()
    for idx, row in themes_df.iterrows():
        moods_str = str(row['오늘의 기분선택'])
        if moods_str and moods_str != 'nan':
            moods = [m.strip() for m in moods_str.split(',') if m.strip()]
            all_moods.update(moods)
    
    # 기분 데이터에 이모지와 색상 추가 (UX 향상)
    mood_mapping = {
        '푹 자고 싶어요': {'emoji': '😴', 'color': '#4A90E2'},
        '낮잠이 필요해요': {'emoji': '💤', 'color': '#9B59B6'},
        '지쳤어요': {'emoji': '😔', 'color': '#E67E22'},
        '귀에서 소리가 나요': {'emoji': '👂', 'color': '#E74C3C'},
        '기운이 없어요': {'emoji': '😞', 'color': '#95A5A6'},
        '조용히 쉬고싶어요': {'emoji': '🧘', 'color': '#27AE60'},
        '기분 전환하고 싶어요': {'emoji': '🌈', 'color': '#F39C12'}
    }
    
    for order, mood in enumerate(sorted(all_moods), 1):
        mood_info = mood_mapping.get(mood, {'emoji': '😊', 'color': '#3498DB'})
        sql = f"INSERT INTO moods (name, emoji, color, display_order) VALUES ('{mood}', '{mood_info['emoji']}', '{mood_info['color']}', {order});"
        sql_statements.append(sql)
    
    sql_statements.append("")
    sql_statements.append("-- ================================")
    sql_statements.append("-- 2. 키워드(KEYWORDS) 데이터 정규화")
    sql_statements.append("-- ================================")
    
    # Excel에서 키워드 추출 및 카테고리화
    all_keywords = {}
    for idx, row in tracks_df.iterrows():
        keywords_str = str(row['효과 키워드(사용자 데이터 참고예정)'])
        if keywords_str and keywords_str != 'nan':
            keywords = [k.strip() for k in keywords_str.split(',') if k.strip()]
            for keyword in keywords:
                all_keywords[keyword] = all_keywords.get(keyword, 0) + 1
    
    # 키워드 카테고리 분류 (의미에 따른 체계화)
    keyword_categories = {
        '수면': '효과',
        '이완': '효과', 
        '안정': '효과',
        '긍정': '감정',
        '활력': '효과',
        '기분전환': '효과',
        '집중': '효과',
        '이명케어': '치료',
        '이명완화': '치료'
    }
    
    for keyword in sorted(all_keywords.keys()):
        category = keyword_categories.get(keyword, '기타')
        sql = f"INSERT INTO keywords (name, category) VALUES ('{keyword}', '{category}');"
        sql_statements.append(sql)
    
    sql_statements.append("")
    sql_statements.append("-- ================================")
    sql_statements.append("-- 3. 테마(THEMES) 데이터 정규화")
    sql_statements.append("-- ================================")
    
    # 테마 데이터 정규화
    for idx, row in themes_df.iterrows():
        theme_code = f'theme_{idx + 1:02d}'  # theme_01, theme_02 형식
        title = str(row['추천테마 제목']).replace("'", "''")
        subtitle = str(row['추천테마 하단 문구']).replace("'", "''") if pd.notna(row['추천테마 하단 문구']) else ""
        description = str(row["테마클릭 후 상단 '음원효과' 설명 문구"]).replace("'", "''")
        
        sql = f"INSERT INTO themes (code, title, subtitle, description, display_order) VALUES ('{theme_code}', '{title}', '{subtitle}', '{description}', {idx + 1});"
        sql_statements.append(sql)
    
    sql_statements.append("")
    sql_statements.append("-- ================================")
    sql_statements.append("-- 4. 트랙(TRACKS) 데이터 정규화")
    sql_statements.append("-- ================================")
    
    # 트랙 데이터 정규화 및 가공
    for idx, row in tracks_df.iterrows():
        track_code = str(row['음원 ID']).strip()
        title = str(row['음원 제목']).replace("'", "''")
        file_name = str(row['파일 이름 (내부 관리용)']).strip()
        duration_str = str(row['음원 길이 (분:초)'])
        bpm = row['음원속도(bpm)'] if pd.notna(row['음원속도(bpm)']) else None
        description = str(row["음원 재생시 '음원 설명'문구"]).replace("'", "''")
        
        # 시간을 초로 변환
        duration_seconds = 0
        try:
            if ':' in duration_str and duration_str != 'nan':
                mins, secs = duration_str.split(':')
                duration_seconds = int(mins) * 60 + int(secs)
        except:
            duration_seconds = 0
        
        # BPM 정규화
        bpm_sql = "NULL"
        if bpm and pd.notna(bpm):
            bpm_str = str(bpm).replace('bpm', '').strip()
            try:
                bpm_val = int(float(bpm_str))
                if 30 <= bpm_val <= 200:  # 유효한 BPM 범위
                    bpm_sql = str(bpm_val)
            except:
                pass
        
        # 카테고리 체계화 (ID 패턴 + 내용 분석)
        category = "자연음"  # 기본값
        is_asmr = "false"
        
        # 제목 분석으로 더 정확한 카테고리 분류
        title_lower = title.lower()
        if any(word in title_lower for word in ['꿈', '자장가', '수면']):
            category = "수면음악"
        elif any(word in title_lower for word in ['빗소리', '물소리', '바람', '새소리']):
            category = "자연음"
        elif any(word in title_lower for word in ['명상', '휴식', '평화']):
            category = "명상음악"
        elif any(word in title_lower for word in ['활력', '기분전환', '햇살']):
            category = "활력음악"
        
        # URL 생성 (실제 파일명 기반)
        url = f"https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/audio-tracks/{file_name}"
        
        sql = f"""INSERT INTO tracks (code, title, artist, url, thumbnail, category, duration_seconds, bpm, file_name, description, is_asmr, display_order) 
VALUES ('{track_code}', '{title}', '에브리슬립', '{url}', NULL, '{category}', {duration_seconds}, {bpm_sql}, '{file_name}', '{description}', {is_asmr}, {idx + 1});"""
        
        sql_statements.append(sql)
    
    sql_statements.append("")
    sql_statements.append("-- ================================")
    sql_statements.append("-- 5. 관계 데이터 정규화")
    sql_statements.append("-- ================================")
    
    # 테마-기분 관계 정규화
    sql_statements.append("-- 테마-기분 관계")
    for idx, row in themes_df.iterrows():
        theme_code = f'theme_{idx + 1:02d}'
        moods_str = str(row['오늘의 기분선택'])
        
        if moods_str and moods_str != 'nan':
            moods = [m.strip() for m in moods_str.split(',') if m.strip()]
            for mood in moods:
                sql = f"""INSERT INTO theme_moods (theme_id, mood_id)
SELECT t.id, m.id FROM themes t, moods m 
WHERE t.code = '{theme_code}' AND m.name = '{mood}';"""
                sql_statements.append(sql)
    
    sql_statements.append("")
    sql_statements.append("-- 테마-트랙 관계")
    
    # 테마-트랙 관계 정규화  
    for idx, row in themes_df.iterrows():
        theme_code = f'theme_{idx + 1:02d}'
        track_ids_str = str(row['포함되는 음원 ID(Sheet 1참고)'])
        
        if track_ids_str and track_ids_str != 'nan':
            # 쉼표와 공백 처리
            track_ids = [t.strip() for t in track_ids_str.replace(',', ' ').split() if t.strip()]
            for order, track_id in enumerate(track_ids, 1):
                if track_id and track_id != ',':  # 빈 값이나 쉼표 제외
                    sql = f"""INSERT INTO theme_tracks (theme_id, track_id, display_order)
SELECT t.id, tr.id, {order} FROM themes t, tracks tr 
WHERE t.code = '{theme_code}' AND tr.code = '{track_id}';"""
                    sql_statements.append(sql)
    
    sql_statements.append("")
    sql_statements.append("-- 트랙-키워드 관계")
    
    # 트랙-키워드 관계 정규화
    for idx, row in tracks_df.iterrows():
        track_code = str(row['음원 ID']).strip()
        keywords_str = str(row['효과 키워드(사용자 데이터 참고예정)'])
        
        if keywords_str and keywords_str != 'nan':
            keywords = [k.strip() for k in keywords_str.split(',') if k.strip()]
            for keyword in keywords:
                if keyword:
                    sql = f"""INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = '{track_code}' AND k.name = '{keyword}';"""
                    sql_statements.append(sql)
    
    return '\n'.join(sql_statements)

if __name__ == "__main__":
    sql_content = generate_proper_normalized_sql()
    
    # 파일에 저장
    with open('/Users/jiwonsong/everysleep/supabase/migrations/011_proper_normalized_data.sql', 'w', encoding='utf-8') as f:
        f.write(sql_content)
    
    print("정규화된 데이터베이스 스키마가 생성되었습니다: 011_proper_normalized_data.sql")
    print(f"총 {len(sql_content.splitlines())} 라인 생성됨")