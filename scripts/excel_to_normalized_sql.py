#!/usr/bin/env python3
import pandas as pd
import re

def generate_normalized_sql():
    # 엑셀 파일 읽기
    tracks_df = pd.read_excel('/Users/jiwonsong/Downloads/에브리슬립_음원리스트.xlsx')
    themes_df = pd.read_excel('/Users/jiwonsong/Downloads/에브리슬립_테마.xlsx')
    
    sql_statements = []
    sql_statements.append("-- 에브리슬립 정규화된 데이터 시딩")
    sql_statements.append("-- Generated from Excel files with normalized schema")
    sql_statements.append("")
    
    # 1. 트랙 데이터 먼저 삽입 (기본 데이터)
    sql_statements.append("-- TRACKS 테이블 데이터")
    
    for idx, row in tracks_df.iterrows():
        track_id = str(row['음원 ID']).strip()
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
        
        # BPM 값에서 숫자만 추출
        bpm_sql = "NULL"
        if bpm and pd.notna(bpm):
            bpm_str = str(bpm).replace('bpm', '').strip()
            try:
                bpm_sql = str(int(float(bpm_str)))
            except:
                bpm_sql = "NULL"
        
        # 카테고리 추론 (ID 패턴 기반)
        category = "기타"
        if track_id.startswith('S'):
            category = "자연음"
        elif track_id.startswith('M'):
            category = "음악"
        elif track_id.startswith('W'):
            category = "백색소음"
        elif track_id.startswith('T'):
            category = "치료음"
        elif track_id.startswith('A'):
            category = "ASMR"
        elif track_id.startswith('N'):
            category = "자연음"
        
        is_asmr = "true" if track_id.startswith('A') else "false"
        
        sql = f"""INSERT INTO tracks (code, title, artist, url, thumbnail, category, duration_seconds, bpm, file_name, description, is_asmr, display_order) 
VALUES ('{track_id}', '{title}', '에브리슬립', 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/audio-tracks/{file_name}', NULL, '{category}', {duration_seconds}, {bpm_sql}, '{file_name}', '{description}', {is_asmr}, {idx + 1});"""
        
        sql_statements.append(sql)
    
    sql_statements.append("")
    sql_statements.append("-- THEMES 테이블 데이터")
    
    # 2. 테마 데이터 삽입
    for idx, row in themes_df.iterrows():
        theme_code = f'theme_{idx + 1}'
        title = str(row['추천테마 제목']).replace("'", "''")
        subtitle = str(row['추천테마 하단 문구']).replace("'", "''") if pd.notna(row['추천테마 하단 문구']) else ""
        description = str(row["테마클릭 후 상단 '음원효과' 설명 문구"]).replace("'", "''")
        
        sql = f"""INSERT INTO themes (code, title, subtitle, description, display_order) 
VALUES ('{theme_code}', '{title}', '{subtitle}', '{description}', {idx + 1});"""
        
        sql_statements.append(sql)
    
    sql_statements.append("")
    sql_statements.append("-- 키워드 데이터 추출 및 삽입")
    
    # 3. 키워드 데이터 추출
    all_keywords = set()
    for idx, row in tracks_df.iterrows():
        keywords_str = str(row['효과 키워드(사용자 데이터 참고예정)'])
        if keywords_str and keywords_str != 'nan':
            keywords = [k.strip() for k in keywords_str.split(',') if k.strip()]
            all_keywords.update(keywords)
    
    # 키워드 카테고리 분류
    effect_keywords = {'수면', '이완', '명상', '집중', '치유', '스트레스완화', '활력', '평온', '안정', '피로회복'}
    genre_keywords = {'자연음', '클래식', '백색소음', 'ASMR', '치료음', '힐링음악', '명상음악'}
    mood_keywords = {'물소리', '빗소리', '새소리', '바람소리', '파도소리', '모닥불소리', '천둥소리'}
    instrument_keywords = {'피아노', '플루트', '현악기', '관악기', '오케스트라'}
    
    for keyword in sorted(all_keywords):
        if not keyword or keyword == 'nan':
            continue
            
        category = "기타"
        if keyword in effect_keywords:
            category = "효과"
        elif keyword in genre_keywords:
            category = "장르"
        elif keyword in mood_keywords:
            category = "분위기"
        elif keyword in instrument_keywords:
            category = "악기"
        
        sql = f"INSERT INTO keywords (name, category) VALUES ('{keyword}', '{category}') ON CONFLICT (name) DO NOTHING;"
        sql_statements.append(sql)
    
    sql_statements.append("")
    sql_statements.append("-- 테마-기분 관계 데이터")
    
    # 4. 테마-기분 관계 데이터
    for idx, row in themes_df.iterrows():
        theme_code = f'theme_{idx + 1}'
        moods_str = str(row['오늘의 기분선택'])
        
        if moods_str and moods_str != 'nan':
            moods = [m.strip() for m in moods_str.split(',') if m.strip()]
            for mood in moods:
                sql = f"""INSERT INTO theme_moods (theme_id, mood_id)
SELECT t.id, m.id FROM themes t, moods m 
WHERE t.code = '{theme_code}' AND m.name = '{mood}';"""
                sql_statements.append(sql)
    
    sql_statements.append("")
    sql_statements.append("-- 테마-트랙 관계 데이터")
    
    # 5. 테마-트랙 관계 데이터
    for idx, row in themes_df.iterrows():
        theme_code = f'theme_{idx + 1}'
        track_ids_str = str(row['포함되는 음원 ID(Sheet 1참고)'])
        
        if track_ids_str and track_ids_str != 'nan':
            track_ids = [t.strip() for t in track_ids_str.split(',') if t.strip()]
            for order, track_id in enumerate(track_ids, 1):
                sql = f"""INSERT INTO theme_tracks (theme_id, track_id, display_order)
SELECT t.id, tr.id, {order} FROM themes t, tracks tr 
WHERE t.code = '{theme_code}' AND tr.code = '{track_id}';"""
                sql_statements.append(sql)
    
    sql_statements.append("")
    sql_statements.append("-- 트랙-키워드 관계 데이터")
    
    # 6. 트랙-키워드 관계 데이터
    for idx, row in tracks_df.iterrows():
        track_id = str(row['음원 ID']).strip()
        keywords_str = str(row['효과 키워드(사용자 데이터 참고예정)'])
        
        if keywords_str and keywords_str != 'nan':
            keywords = [k.strip() for k in keywords_str.split(',') if k.strip()]
            for keyword in keywords:
                if keyword:
                    sql = f"""INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = '{track_id}' AND k.name = '{keyword}';"""
                    sql_statements.append(sql)
    
    return '\n'.join(sql_statements)

if __name__ == "__main__":
    sql_content = generate_normalized_sql()
    
    # 파일에 저장
    with open('/Users/jiwonsong/everysleep/supabase/migrations/010_seed_normalized_data.sql', 'w', encoding='utf-8') as f:
        f.write(sql_content)
    
    print("정규화된 데이터 시딩 SQL이 생성되었습니다: 010_seed_normalized_data.sql")
    print(f"총 {len(sql_content.splitlines())} 라인 생성됨")