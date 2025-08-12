#!/usr/bin/env python3
import pandas as pd
import json

def analyze_excel_data():
    # 엑셀 파일 읽기
    tracks_df = pd.read_excel('/Users/jiwonsong/Downloads/에브리슬립_음원리스트.xlsx')
    themes_df = pd.read_excel('/Users/jiwonsong/Downloads/에브리슬립_테마.xlsx')
    
    print('=== 트랙 데이터 구조 분석 ===')
    print('컬럼들:', list(tracks_df.columns))
    print('트랙 수:', len(tracks_df))
    print()
    
    # 샘플 데이터 확인
    print('첫 3개 트랙 샘플:')
    for idx, row in tracks_df.head(3).iterrows():
        print(f"ID: {row['음원 ID']}")
        print(f"제목: {row['음원 제목']}")  
        print(f"키워드: {row['효과 키워드(사용자 데이터 참고예정)']}")
        print()
    
    print('=== 테마 데이터 구조 분석 ===')
    print('컬럼들:', list(themes_df.columns))
    print('테마 수:', len(themes_df))
    print()
    
    # 샘플 테마 데이터
    print('첫 3개 테마 샘플:')
    for idx, row in themes_df.head(3).iterrows():
        print(f"제목: {row['추천테마 제목']}")
        print(f"기분: {row['오늘의 기분선택']}")
        print(f"포함 음원: {row['포함되는 음원 ID(Sheet 1참고)']}")
        print()
    
    # 키워드 정규화 분석
    print('=== 키워드 정규화 분석 ===')
    all_keywords = set()
    keyword_counts = {}
    
    for idx, row in tracks_df.iterrows():
        keywords_str = str(row['효과 키워드(사용자 데이터 참고예정)'])
        if keywords_str and keywords_str != 'nan':
            keywords = [k.strip() for k in keywords_str.split(',') if k.strip()]
            for keyword in keywords:
                all_keywords.add(keyword)
                keyword_counts[keyword] = keyword_counts.get(keyword, 0) + 1
    
    print('고유 키워드 수:', len(all_keywords))
    print('키워드 사용 빈도 (상위 10개):')
    sorted_keywords = sorted(keyword_counts.items(), key=lambda x: x[1], reverse=True)
    for keyword, count in sorted_keywords[:10]:
        print(f"  {keyword}: {count}번")
    
    # 기분 정규화 분석
    print('\n=== 기분 정규화 분석 ===')
    all_moods = set()
    
    for idx, row in themes_df.iterrows():
        moods_str = str(row['오늘의 기분선택'])
        if moods_str and moods_str != 'nan':
            moods = [m.strip() for m in moods_str.split(',') if m.strip()]
            all_moods.update(moods)
    
    print('고유 기분 수:', len(all_moods))
    print('기분 목록:', sorted(list(all_moods)))
    
    # 데이터 정합성 체크
    print('\n=== 데이터 정합성 체크 ===')
    
    # 트랙 ID 중복 체크
    track_ids = tracks_df['음원 ID'].tolist()
    unique_track_ids = set(track_ids)
    if len(track_ids) != len(unique_track_ids):
        print(f"⚠️  트랙 ID 중복 발견: {len(track_ids) - len(unique_track_ids)}개")
    else:
        print("✅ 트랙 ID 중복 없음")
    
    # 테마에서 참조하는 트랙 ID 검증
    referenced_track_ids = set()
    missing_track_ids = set()
    
    for idx, row in themes_df.iterrows():
        track_ids_str = str(row['포함되는 음원 ID(Sheet 1참고)'])
        if track_ids_str and track_ids_str != 'nan':
            track_ids = [t.strip() for t in track_ids_str.split(',') if t.strip()]
            referenced_track_ids.update(track_ids)
            
            for track_id in track_ids:
                if track_id not in unique_track_ids:
                    missing_track_ids.add(track_id)
    
    if missing_track_ids:
        print(f"⚠️  존재하지 않는 트랙 ID 참조: {missing_track_ids}")
    else:
        print("✅ 테마-트랙 참조 무결성 양호")
    
    # 정규화 제안
    print('\n=== 정규화 제안사항 ===')
    
    # 1. 카테고리 정규화
    categories = set()
    for idx, row in tracks_df.iterrows():
        track_id = str(row['음원 ID'])
        if track_id.startswith('S'):
            categories.add('자연음')
        elif track_id.startswith('M'):
            categories.add('음악')
        elif track_id.startswith('W'):
            categories.add('백색소음')
        elif track_id.startswith('T'):
            categories.add('치료음')
        elif track_id.startswith('A'):
            categories.add('ASMR')
        elif track_id.startswith('N'):
            categories.add('자연음')
    
    print(f"제안 카테고리: {sorted(list(categories))}")
    
    # 2. 키워드 카테고리화
    effect_keywords = {'수면', '이완', '명상', '집중', '치유', '스트레스완화', '활력', '평온'}
    mood_keywords = {'물소리', '빗소리', '새소리', '바람소리', '파도소리'}
    
    effects = []
    moods = []
    others = []
    
    for keyword in all_keywords:
        if any(eff in keyword for eff in effect_keywords):
            effects.append(keyword)
        elif any(mood in keyword for mood in mood_keywords):
            moods.append(keyword)
        else:
            others.append(keyword)
    
    print(f"효과 키워드: {len(effects)}개")
    print(f"분위기 키워드: {len(moods)}개") 
    print(f"기타 키워드: {len(others)}개")
    
    return {
        'tracks_count': len(tracks_df),
        'themes_count': len(themes_df),
        'unique_keywords': len(all_keywords),
        'unique_moods': len(all_moods),
        'categories': sorted(list(categories)),
        'all_keywords': sorted(list(all_keywords)),
        'all_moods': sorted(list(all_moods))
    }

if __name__ == "__main__":
    result = analyze_excel_data()
    
    # 결과를 JSON으로 저장
    with open('/Users/jiwonsong/everysleep/analysis_result.json', 'w', encoding='utf-8') as f:
        json.dump(result, f, ensure_ascii=False, indent=2)
    
    print('\n=== 분석 완료 ===')
    print('분석 결과가 analysis_result.json에 저장되었습니다.')