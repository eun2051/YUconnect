import 'package:flutter/material.dart';
import '../../models/student_event.dart';
import '../../components/event_detail_modal.dart';

/// 총학생회 행사 전체 목록 화면
class StudentCouncilEventsListScreen extends StatefulWidget {
  const StudentCouncilEventsListScreen({super.key});

  @override
  State<StudentCouncilEventsListScreen> createState() =>
      _StudentCouncilEventsListScreenState();
}

class _StudentCouncilEventsListScreenState
    extends State<StudentCouncilEventsListScreen> {
  final List<StudentEvent> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  /// 행사 목록 로드
  Future<void> _loadEvents() async {
    try {
      // TODO: 실제 Firebase에서 데이터를 가져오도록 구현
      // 현재는 샘플 데이터 사용
      await Future.delayed(const Duration(milliseconds: 500)); // 로딩 시뮬레이션

      final sampleEvents = [
        StudentEvent(
          id: '1',
          title: '들풀제',
          description:
              '영남대학교 대표 축제인 들풀제가 개최됩니다. 다양한 공연과 부스, 먹거리가 준비되어 있으니 많은 참여 바랍니다.',
          location: '영남대학교 천연잔디구장',
          startDate: DateTime(2024, 9, 30),
          endDate: DateTime(2024, 9, 30).add(const Duration(hours: 2)),
          imageUrl: '',
          category: '총학생회',
          organizer: 'admin',
          status: 'upcoming',
        ),
        StudentEvent(
          id: '2',
          title: '플리마켓 신청',
          description: '들풀제 기간 중 진행되는 플리마켓에 참여하실 분들은 미리 신청해주세요. 선착순 마감됩니다.',
          location: '들풀제 플리마켓',
          startDate: DateTime(2024, 10, 4),
          endDate: DateTime(2024, 10, 4).add(const Duration(hours: 2)),
          imageUrl: '',
          category: '총학생회',
          organizer: 'admin',
          status: 'upcoming',
        ),
        StudentEvent(
          id: '3',
          title: '학과 체육대회',
          description: '각 학과별로 참여하는 체육대회입니다. 축구, 농구, 배구 등 다양한 종목에 참여할 수 있습니다.',
          location: '영남대학교 체육관',
          startDate: DateTime(2024, 11, 15),
          endDate: DateTime(2024, 11, 15).add(const Duration(hours: 2)),
          imageUrl: '',
          category: '총학생회',
          organizer: 'admin',
          status: 'upcoming',
        ),
        StudentEvent(
          id: '4',
          title: '겨울 축제',
          description: '겨울을 맞이하는 특별한 축제입니다. 따뜻한 음료와 함께 즐거운 시간을 보내세요.',
          location: '영남대학교 광장',
          startDate: DateTime(2024, 12, 20),
          endDate: DateTime(2024, 12, 20).add(const Duration(hours: 2)),
          imageUrl: '',
          category: '총학생회',
          organizer: 'admin',
          status: 'upcoming',
        ),
        StudentEvent(
          id: '5',
          title: '신입생 환영회',
          description: '새로운 학기를 맞이하는 신입생들을 위한 환영회입니다. 선배들과의 만남의 시간을 가져보세요.',
          location: '영남대학교 대강당',
          startDate: DateTime(2025, 3, 5),
          endDate: DateTime(2025, 3, 5).add(const Duration(hours: 2)),
          imageUrl: '',
          category: '총학생회',
          organizer: 'admin',
          status: 'upcoming',
        ),
      ];

      setState(() {
        _events.clear();
        _events.addAll(sampleEvents);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('데이터를 불러오는 중 오류가 발생했습니다: $e')));
      }
    }
  }

  /// 행사 상세 모달 표시
  void _showEventDetail(StudentEvent event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        child: EventDetailModal(event: event),
      ),
    );
  }

  /// 날짜 포맷팅
  String _formatDate(DateTime date) {
    final months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return '${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}';
  }

  /// 행사 상태 확인
  String _getEventStatus(DateTime eventDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final event = DateTime(eventDate.year, eventDate.month, eventDate.day);

    if (event.isBefore(today)) {
      return '종료';
    } else if (event.isAtSameMomentAs(today)) {
      return '진행중';
    } else {
      return '예정';
    }
  }

  /// 상태별 색상
  Color _getStatusColor(String status) {
    switch (status) {
      case '진행중':
        return const Color(0xFF10B981);
      case '예정':
        return const Color(0xFF006FFD);
      case '종료':
        return const Color(0xFF6B7280);
      default:
        return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2024)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '총학생회 행사',
          style: TextStyle(
            color: Color(0xFF1F2024),
            fontSize: 22,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF006FFD)),
                  SizedBox(height: 16),
                  Text(
                    '행사 목록을 불러오는 중...',
                    style: TextStyle(fontSize: 16, color: Color(0xFF71727A)),
                  ),
                ],
              ),
            )
          : _events.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 64, color: Color(0xFFE5E7EB)),
                  SizedBox(height: 16),
                  Text(
                    '등록된 행사가 없습니다',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // 행사 개수 표시
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F7FF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFF006FFD).withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.event_note,
                        color: Color(0xFF006FFD),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '총 ${_events.length}개의 행사가 등록되어 있습니다',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF006FFD),
                        ),
                      ),
                    ],
                  ),
                ),

                // 행사 목록
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _events.length,
                    itemBuilder: (context, index) {
                      final event = _events[index];
                      final status = _getEventStatus(event.startDate);
                      final statusColor = _getStatusColor(status);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: statusColor.withOpacity(0.2),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => _showEventDetail(event),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  // 날짜 표시
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          _formatDate(
                                            event.startDate,
                                          ).split(' ')[0],
                                          style: TextStyle(
                                            color: statusColor,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          _formatDate(
                                            event.startDate,
                                          ).split(' ')[1],
                                          style: TextStyle(
                                            color: statusColor,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),

                                  // 행사 정보
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // 상태와 제목
                                        Row(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: statusColor.withOpacity(
                                                  0.1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                status,
                                                style: TextStyle(
                                                  color: statusColor,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                event.title,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF1F2024),
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),

                                        // 설명
                                        Text(
                                          event.description,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF71727A),
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),

                                        // 등록일
                                        Text(
                                          '등록일: ${event.startDate.year}년 ${event.startDate.month}월 ${event.startDate.day}일',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF9CA3AF),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // 화살표 아이콘
                                  const Icon(
                                    Icons.chevron_right,
                                    color: Color(0xFF9CA3AF),
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
