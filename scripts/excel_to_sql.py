#!/usr/bin/env python3
import pandas as pd

def generate_sql():
    # 엑셀 파일 읽기
    tracks_df = pd.read_excel('/Users/jiwonsong/Downloads/에브리슬립_음원리스트.xlsx')
    themes_df = pd.read_excel('/Users/jiwonsong/Downloads/에브리슬립_테마.xlsx')
    
    sql_statements = []
    sql_statements.append("-- 에브리슬립 데이터 시딩")
    sql_statements.append("-- Generated from Excel files")
    sql_statements.append("")
    
    # 트랙 데이터 SQL 생성
    sql_statements.append("-- TRACKS 테이블 데이터")
    
    for idx, row in tracks_df.iterrows():
        track_id = row['음원 ID']
        title = str(row['음원 제목']).replace("'", "''")
        file_name = row['파일 이름 (내부 관리용)']
        duration_str = str(row['음원 길이 (분:초)'])
        bpm = row['음원속도(bpm)'] if pd.notna(row['음원속도(bpm)']) else None
        description = str(row["음원 재생시 '음원 설명'문구"]).replace("'", "''")
        keywords = str(row['효과 키워드(사용자 데이터 참고예정)'])
        
        # 시간을 초로 변환
        try:
            if ':' in duration_str:
                mins, secs = duration_str.split(':')
                duration_seconds = int(mins) * 60 + int(secs)
            else:
                duration_seconds = 0
        except:
            duration_seconds = 0
        
        # 키워드 배열로 변환
        keywords_array = []
        if keywords and keywords != 'nan':
            keywords_array = [k.strip() for k in keywords.split(',') if k.strip()]
        
        keywords_sql = "ARRAY[" + ",".join([f"'{k}'" for k in keywords_array]) + "]"
        
        # BPM 값에서 숫자만 추출
        bpm_sql = "NULL"
        if bpm and pd.notna(bpm):
            bpm_str = str(bpm).replace('bpm', '').strip()
            try:
                bpm_sql = str(int(bpm_str))
            except:
                bpm_sql = "NULL"
        
        sql = f"""INSERT INTO tracks (id, title, artist, url, file_name, duration_seconds, bpm, description, effect_keywords, display_order) 
VALUES ('{track_id}', '{title}', '에브리슬립', 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/audio-tracks/{file_name}', '{file_name}', {duration_seconds}, {bpm_sql}, '{description}', {keywords_sql}, {idx + 1});"""
        
        sql_statements.append(sql)
    
    sql_statements.append("")
    sql_statements.append("-- THEMES 테이블 데이터")
    
    # 테마 데이터 SQL 생성
    for idx, row in themes_df.iterrows():
        theme_id = f'theme_{idx + 1}'
        title = str(row['추천테마 제목']).replace("'", "''")
        subtitle = str(row['추천테마 하단 문구']).replace("'", "''")
        description = str(row["테마클릭 후 상단 '음원효과' 설명 문구"]).replace("'", "''")
        track_ids_str = str(row['포함되는 음원 ID(Sheet 1참고)'])
        moods_str = str(row['오늘의 기분선택'])
        
        # 트랙 ID 배열로 변환
        track_ids = []
        if track_ids_str and track_ids_str != 'nan':
            track_ids = [t.strip() for t in track_ids_str.split(',') if t.strip()]
        
        # 기분 배열로 변환
        moods = []
        if moods_str and moods_str != 'nan':
            moods = [m.strip() for m in moods_str.split(',') if m.strip()]
        
        track_ids_sql = "ARRAY[" + ",".join([f"'{t}'" for t in track_ids]) + "]"
        moods_sql = "ARRAY[" + ",".join([f"'{m}'" for m in moods]) + "]"
        
        sql = f"""INSERT INTO themes (id, title, subtitle, description, track_ids, moods, display_order) 
VALUES ('{theme_id}', '{title}', '{subtitle}', '{description}', {track_ids_sql}, {moods_sql}, {idx + 1});"""
        
        sql_statements.append(sql)
    
    return '\n'.join(sql_statements)

if __name__ == "__main__":
    sql_content = generate_sql()
    print(sql_content)