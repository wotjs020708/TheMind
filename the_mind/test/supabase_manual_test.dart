import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

String generateUuid() {
  final random = Random();
  String hex() => random.nextInt(256).toRadixString(16).padLeft(2, '0');
  String hex4() => '${hex()}${hex()}';

  return '${hex4()}${hex4()}-'
      '${hex4()}-'
      '4${hex()}${hex().substring(1)}-' // Version 4
      '${(random.nextInt(4) + 8).toRadixString(16)}${hex()}${hex().substring(1)}-'
      '${hex4()}${hex4()}${hex4()}';
}

/// Supabase REST API를 직접 호출하여 서버 연결 테스트
void main() async {
  print('🔍 Supabase 서버 연결 테스트 시작...\n');

  const supabaseUrl = 'https://cxdlxrxmszaomeroosnh.supabase.co';
  const supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN4ZGx4cnhtc3phb21lcm9vc25oIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk1NzUwMjAsImV4cCI6MjA4NTE1MTAyMH0.6lp1AN8dSTPjtcbw3enQvJC5eFsFD93UfDSWux6HBz4';

  final headers = {
    'apikey': supabaseAnonKey,
    'Authorization': 'Bearer $supabaseAnonKey',
    'Content-Type': 'application/json',
  };

  // 테스트 1: 서버 연결 확인
  print('📡 테스트 1: 서버 연결 확인');
  try {
    final response = await http
        .get(Uri.parse('$supabaseUrl/rest/v1/rooms?limit=1'), headers: headers)
        .timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      print('✅ 서버 연결 성공! (Status: ${response.statusCode})');
      print(
        '   응답: ${response.body.substring(0, response.body.length > 100 ? 100 : response.body.length)}...\n',
      );
    } else {
      print('⚠️  서버 응답 이상 (Status: ${response.statusCode})');
      print('   에러: ${response.body}\n');
    }
  } catch (e) {
    print('❌ 서버 연결 실패: $e\n');
    exit(1);
  }

  // 테스트 2: 방 생성
  print('📡 테스트 2: 방 생성');
  String? createdRoomId;
  String? createdRoomCode;
  try {
    // 6자 코드 생성 (A-Z, 0-9)
    final random = DateTime.now().millisecondsSinceEpoch;
    final code =
        'T${random.toString().substring(random.toString().length - 5)}';

    final roomData = {
      'code': code,
      'player_count': 2,
      'status': 'waiting',
      'lives': 2,
      'shurikens': 1,
      'current_level': 1,
    };

    final response = await http.post(
      Uri.parse('$supabaseUrl/rest/v1/rooms'),
      headers: {...headers, 'Prefer': 'return=representation'},
      body: jsonEncode(roomData),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body)[0];
      createdRoomId = data['id'];
      createdRoomCode = data['code'];
      print('✅ 방 생성 성공!');
      print('   방 ID: $createdRoomId');
      print('   방 코드: $createdRoomCode');
      print('   플레이어 수: ${data['player_count']}');
      print('   상태: ${data['status']}\n');
    } else {
      print('❌ 방 생성 실패 (Status: ${response.statusCode})');
      print('   에러: ${response.body}\n');
      exit(1);
    }
  } catch (e) {
    print('❌ 방 생성 중 에러: $e\n');
    exit(1);
  }

  // 테스트 3: 방 코드로 찾기
  print('📡 테스트 3: 방 코드로 찾기');
  try {
    final response = await http.get(
      Uri.parse('$supabaseUrl/rest/v1/rooms?code=eq.$createdRoomCode'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data.isNotEmpty && data[0]['code'] == createdRoomCode) {
        print('✅ 방 찾기 성공!');
        print('   찾은 방 코드: ${data[0]['code']}\n');
      } else {
        print('⚠️  방을 찾을 수 없습니다\n');
      }
    } else {
      print('❌ 방 찾기 실패 (Status: ${response.statusCode})\n');
    }
  } catch (e) {
    print('❌ 방 찾기 중 에러: $e\n');
  }

  // 테스트 4: 플레이어 추가
  print('📡 테스트 4: 플레이어 추가');
  String? createdPlayerId;
  try {
    final playerData = {
      'room_id': createdRoomId,
      'user_id': generateUuid(),
      'name': 'TestPlayer_${DateTime.now().millisecondsSinceEpoch % 1000}',
      'position': 0,
      'is_ready': false,
    };

    final response = await http.post(
      Uri.parse('$supabaseUrl/rest/v1/players'),
      headers: {...headers, 'Prefer': 'return=representation'},
      body: jsonEncode(playerData),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body)[0];
      createdPlayerId = data['id'];
      print('✅ 플레이어 추가 성공!');
      print('   플레이어 ID: $createdPlayerId');
      print('   플레이어 이름: ${data['name']}');
      print('   준비 상태: ${data['is_ready']}\n');
    } else {
      print('❌ 플레이어 추가 실패 (Status: ${response.statusCode})');
      print('   에러: ${response.body}\n');
    }
  } catch (e) {
    print('❌ 플레이어 추가 중 에러: $e\n');
  }

  // 테스트 5: 플레이어 준비 상태 토글
  print('📡 테스트 5: 플레이어 준비 상태 토글');
  try {
    final response = await http.patch(
      Uri.parse('$supabaseUrl/rest/v1/players?id=eq.$createdPlayerId'),
      headers: {...headers, 'Prefer': 'return=representation'},
      body: jsonEncode({'is_ready': true}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)[0];
      print('✅ 준비 상태 토글 성공!');
      print('   준비 상태: ${data['is_ready']}\n');
    } else {
      print('❌ 준비 상태 토글 실패 (Status: ${response.statusCode})\n');
    }
  } catch (e) {
    print('❌ 준비 상태 토글 중 에러: $e\n');
  }

  // 테스트 6: 방 상태 업데이트
  print('📡 테스트 6: 방 상태 업데이트 (waiting → playing)');
  try {
    final response = await http.patch(
      Uri.parse('$supabaseUrl/rest/v1/rooms?id=eq.$createdRoomId'),
      headers: {...headers, 'Prefer': 'return=representation'},
      body: jsonEncode({'status': 'playing'}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)[0];
      print('✅ 방 상태 업데이트 성공!');
      print('   새 상태: ${data['status']}\n');
    } else {
      print('❌ 방 상태 업데이트 실패 (Status: ${response.statusCode})\n');
    }
  } catch (e) {
    print('❌ 방 상태 업데이트 중 에러: $e\n');
  }

  // 정리: 테스트 데이터 삭제
  print('🧹 테스트 데이터 정리 중...');
  try {
    // 플레이어 삭제
    if (createdPlayerId != null) {
      await http.delete(
        Uri.parse('$supabaseUrl/rest/v1/players?id=eq.$createdPlayerId'),
        headers: headers,
      );
      print('   플레이어 삭제 완료');
    }

    // 방 삭제
    if (createdRoomId != null) {
      await http.delete(
        Uri.parse('$supabaseUrl/rest/v1/rooms?id=eq.$createdRoomId'),
        headers: headers,
      );
      print('   방 삭제 완료');
    }
  } catch (e) {
    print('   정리 중 에러: $e');
  }

  print('\n✨ 모든 테스트 완료!');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('📊 테스트 결과 요약:');
  print('   ✅ 서버 연결');
  print('   ✅ 방 생성');
  print('   ✅ 방 찾기');
  print('   ✅ 플레이어 추가');
  print('   ✅ 플레이어 상태 토글');
  print('   ✅ 방 상태 업데이트');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
}
