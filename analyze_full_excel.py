import pandas as pd

# 음원리스트 전체 읽기
music_df = pd.read_excel('/Users/jiwonsong/everysleep/docs/에브리슬립_음원리스트.xlsx')
print('=== 전체 음원 리스트 (36개) ===')
for idx, row in music_df.iterrows():
    print(f"\n[{row['음원 ID']}] {row['음원 제목']}:")
    print(f"  - 파일명: {row['파일 이름 (내부 관리용)']}")
    print(f"  - 길이: {row['음원 길이 (분:초)']}")
    print(f"  - BPM: {row['음원속도(bpm)']}")
    print(f"  - 효과: {row['효과 키워드(사용자 데이터 참고예정)']}")
    desc = str(row['음원 재생시 \'음원 설명\'문구'])
    print(f"  - 설명: {desc[:60]}..." if len(desc) > 60 else f"  - 설명: {desc}")

# 테마별 음원 매핑 확인
print('\n\n=== 테마별 음원 매핑 ===')
theme_df = pd.read_excel('/Users/jiwonsong/everysleep/docs/에브리슬립_테마.xlsx')
for idx, row in theme_df.iterrows():
    print(f"\n{row['추천테마 제목']}:")
    print(f"  - 포함 음원: {row['포함되는 음원 ID(Sheet 1참고)']}")
    print(f"  - 연결 기분: {row['오늘의 기분선택']}")
    
# 모든 음원 ID 수집
all_track_ids = set()
for idx, row in theme_df.iterrows():
    track_ids = str(row['포함되는 음원 ID(Sheet 1참고)']).split(', ')
    all_track_ids.update([tid.strip() for tid in track_ids if tid.strip()])

print(f"\n\n=== 통계 ===")
print(f"총 음원 수: {len(music_df)}")
print(f"총 테마 수: {len(theme_df)}")
print(f"테마에 포함된 고유 음원 수: {len(all_track_ids)}")
print(f"테마에 포함된 음원 ID: {sorted(all_track_ids)}")