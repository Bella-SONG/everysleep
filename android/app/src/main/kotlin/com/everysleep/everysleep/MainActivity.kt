package com.everysleep.everysleep

import com.ryanheise.audioservice.AudioServiceActivity

class MainActivity : AudioServiceActivity() {
    // AudioServiceActivity를 상속받아 백그라운드 오디오 서비스 지원
    // Supabase OAuth는 app_links가 자동으로 처리
}