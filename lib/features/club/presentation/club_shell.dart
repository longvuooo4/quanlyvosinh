import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../domain/club_snapshot.dart';
import 'club_view_model.dart';

class ClubShell extends StatelessWidget {
  const ClubShell({super.key, required this.model, required this.section});

  final ClubViewModel model;
  final String section;
  static const routes = ['overview', 'students', 'classes', 'management'];

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: model,
    builder: (context, _) => Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              model.snapshot.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Text(
              'Quản lý Karate',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          if (model.saving)
            const Padding(
              padding: EdgeInsets.all(18),
              child: SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            ),
          IconButton(
            onPressed: () => _renameClub(context),
            tooltip: 'Đổi tên CLB',
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: routes.indexOf(section),
        onDestinationSelected: (index) => context.go('/${routes[index]}'),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Tổng quan',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Võ sinh',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Lớp tập',
          ),
          NavigationDestination(
            icon: Icon(Icons.fact_check_outlined),
            selectedIcon: Icon(Icons.fact_check),
            label: 'Vận hành',
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: model.loading
                ? const Center(child: CircularProgressIndicator())
                : model.error != null && model.snapshot.students.isEmpty
                ? _ErrorState(model: model)
                : ListView(
                    padding: const EdgeInsets.fromLTRB(18, 20, 18, 32),
                    children: switch (section) {
                      'students' => _students(context),
                      'classes' => _classes(context),
                      'management' => _management(context),
                      _ => _overview(context),
                    },
                  ),
          ),
        ),
      ),
    ),
  );

  List<Widget> _overview(BuildContext context) => [
    Text('Hôm nay', style: Theme.of(context).textTheme.headlineMedium),
    const SizedBox(height: 6),
    Text(
      _dateLabel(DateTime.now()),
      style: Theme.of(context).textTheme.bodyLarge
          ?.copyWith(color: Colors.grey[700]),
    ),
    const SizedBox(height: 20),
    Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _Metric('Đang tập', '${model.activeStudents}', Icons.person_outline),
        _Metric(
          'Lớp Karate',
          '${model.snapshot.classes.length}',
          Icons.groups_outlined,
        ),
        _Metric(
          'Số dư',
          _currency(model.balance),
          Icons.account_balance_wallet_outlined,
        ),
      ],
    ),
    const SizedBox(height: 26),
    Text('Truy cập nhanh', style: Theme.of(context).textTheme.titleLarge),
    const SizedBox(height: 10),
    _QuickAction(
      icon: Icons.person_add_alt_1,
      title: 'Thêm võ sinh',
      subtitle: 'Tạo hồ sơ và xếp lớp',
      onTap: () => _editStudent(context),
    ),
    _QuickAction(
      icon: Icons.add_box_outlined,
      title: 'Tạo lớp tập',
      subtitle: 'Lịch học, HLV và địa điểm',
      onTap: () => _editClass(context),
    ),
    _QuickAction(
      icon: Icons.fact_check_outlined,
      title: 'Điểm danh và tài chính',
      subtitle: 'Vận hành CLB trong ngày',
      onTap: () => context.go('/management'),
    ),
    if (model.snapshot.students.isEmpty && model.snapshot.classes.isEmpty) ...[
      const SizedBox(height: 16),
      const _EmptyCard(
        icon: Icons.sports_martial_arts,
        title: 'Bắt đầu thiết lập CLB',
        message: 'Hãy tạo lớp Karate, sau đó thêm võ sinh và xếp lớp.',
      ),
    ],
  ];

  List<Widget> _students(BuildContext context) => [
    _SectionHeader(
      title: 'Võ sinh',
      actionLabel: 'Thêm',
      actionIcon: Icons.person_add_alt_1,
      onPressed: () => _editStudent(context),
    ),
    const SizedBox(height: 12),
    TextField(
      onChanged: model.search,
      decoration: const InputDecoration(
        hintText: 'Tìm tên, mã hoặc số điện thoại',
        prefixIcon: Icon(Icons.search),
      ),
    ),
    const SizedBox(height: 16),
    Text('${model.students.length} võ sinh'),
    const SizedBox(height: 8),
    if (model.students.isEmpty)
      const _EmptyCard(
        icon: Icons.people_outline,
        title: 'Chưa có võ sinh',
        message: 'Thêm hồ sơ đầu tiên để bắt đầu quản lý.',
      ),
    for (final student in model.students)
      Card(
        child: ListTile(
          contentPadding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
          leading: CircleAvatar(
            backgroundColor: student.status == StudentStatus.active
                ? const Color(0xffffdad6)
                : const Color(0xffe6e1e5),
            child: Text(
              student.name.trim().isEmpty
                  ? '?'
                  : student.name.trim()[0].toUpperCase(),
            ),
          ),
          title: Text(
            student.name,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              [
                student.id,
                student.belt,
                if (student.phone.isNotEmpty) student.phone,
              ].join(' · '),
            ),
          ),
          trailing: PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') _editStudent(context, student: student);
              if (value == 'delete') _deleteStudent(context, student);
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Chỉnh sửa')),
              PopupMenuItem(value: 'delete', child: Text('Xóa')),
            ],
          ),
          onTap: () => _editStudent(context, student: student),
        ),
      ),
  ];

  List<Widget> _classes(BuildContext context) => [
    _SectionHeader(
      title: 'Lớp Karate',
      actionLabel: 'Tạo lớp',
      actionIcon: Icons.add,
      onPressed: () => _editClass(context),
    ),
    const SizedBox(height: 14),
    if (model.snapshot.classes.isEmpty)
      const _EmptyCard(
        icon: Icons.calendar_month_outlined,
        title: 'Chưa có lớp tập',
        message: 'Tạo lớp để xếp lịch và ghi danh võ sinh.',
      ),
    for (final item in model.snapshot.classes)
      Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _editClass(context, karateClass: item),
                    tooltip: 'Chỉnh sửa',
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    onPressed: () => _deleteClass(context, item),
                    tooltip: 'Xóa lớp',
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _InfoLine(Icons.schedule, item.schedule),
              _InfoLine(
                Icons.person_outline,
                item.coach.isEmpty ? 'Chưa phân công HLV' : item.coach,
              ),
              _InfoLine(
                Icons.location_on_outlined,
                item.location.isEmpty ? 'Chưa nhập địa điểm' : item.location,
              ),
              const Divider(height: 26),
              Text(
                '${model.snapshot.students.where((s) => s.classIds.contains(item.id)).length} võ sinh',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
  ];

  List<Widget> _management(BuildContext context) => [
    Text('Vận hành', style: Theme.of(context).textTheme.headlineMedium),
    const SizedBox(height: 16),
    _AttendancePanel(model: model),
    const SizedBox(height: 20),
    _FinancePanel(model: model),
    const SizedBox(height: 20),
    Card(
      child: ListTile(
        leading: const Icon(Icons.info_outline),
        title: const Text('Karate Manager'),
        subtitle: const Text(
          'Phiên bản 1.0.0 · Dữ liệu được lưu trên thiết bị này',
        ),
        onTap: () => showAboutDialog(
          context: context,
          applicationName: 'Karate Manager',
          applicationVersion: '1.0.0',
          children: const [Text('Ứng dụng quản lý câu lạc bộ Karate.')],
        ),
      ),
    ),
  ];

  Future<void> _renameClub(BuildContext context) async {
    final controller = TextEditingController(text: model.snapshot.name);
    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tên câu lạc bộ'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Tên CLB'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value != null && value.isNotEmpty) await model.renameClub(value);
  }

  Future<void> _editStudent(
    BuildContext context, {
    KarateStudent? student,
  }) async {
    final result = await showDialog<KarateStudent>(
      context: context,
      builder: (_) =>
          _StudentDialog(student: student, classes: model.snapshot.classes),
    );
    if (result != null) await model.upsertStudent(result);
  }

  Future<void> _editClass(
    BuildContext context, {
    KarateClass? karateClass,
  }) async {
    final result = await showDialog<KarateClass>(
      context: context,
      builder: (_) => _ClassDialog(karateClass: karateClass),
    );
    if (result != null) await model.upsertClass(result);
  }

  Future<void> _deleteStudent(
    BuildContext context,
    KarateStudent student,
  ) async {
    final ok = await _confirm(
      context,
      'Xóa võ sinh?',
      'Hồ sơ ${student.name} và dữ liệu điểm danh liên quan sẽ bị xóa.',
    );
    if (ok) await model.deleteStudent(student.id);
  }

  Future<void> _deleteClass(BuildContext context, KarateClass item) async {
    final ok = await _confirm(
      context,
      'Xóa lớp?',
      'Lớp ${item.name} và lịch sử điểm danh của lớp sẽ bị xóa.',
    );
    if (ok) await model.deleteClass(item.id);
  }
}

class _StudentDialog extends StatefulWidget {
  const _StudentDialog({required this.student, required this.classes});
  final KarateStudent? student;
  final List<KarateClass> classes;

  @override
  State<_StudentDialog> createState() => _StudentDialogState();
}

class _StudentDialogState extends State<_StudentDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late String _belt;
  late StudentStatus _status;
  late Set<String> _classIds;

  static const belts = [
    'Đai trắng',
    'Đai vàng',
    'Đai cam',
    'Đai xanh lá',
    'Đai xanh dương',
    'Đai nâu',
    'Đai đen',
  ];

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.student?.name ?? '');
    _phone = TextEditingController(text: widget.student?.phone ?? '');
    _belt = widget.student?.belt ?? belts.first;
    _status = widget.student?.status ?? StudentStatus.active;
    _classIds = {...?widget.student?.classIds};
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.student == null ? 'Thêm võ sinh' : 'Sửa võ sinh'),
    content: SizedBox(
      width: 520,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _name,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Họ và tên *'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Vui lòng nhập họ tên'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Số điện thoại'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _belt,
                decoration: const InputDecoration(labelText: 'Cấp đai'),
                items: belts
                    .map(
                      (item) =>
                          DropdownMenuItem(value: item, child: Text(item)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _belt = value ?? _belt),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<StudentStatus>(
                initialValue: _status,
                decoration: const InputDecoration(labelText: 'Trạng thái'),
                items: const [
                  DropdownMenuItem(
                    value: StudentStatus.active,
                    child: Text('Đang tập'),
                  ),
                  DropdownMenuItem(
                    value: StudentStatus.paused,
                    child: Text('Tạm nghỉ'),
                  ),
                ],
                onChanged: (value) =>
                    setState(() => _status = value ?? _status),
              ),
              if (widget.classes.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Xếp lớp',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                for (final item in widget.classes)
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _classIds.contains(item.id),
                    title: Text(item.name),
                    onChanged: (value) => setState(
                      () => value == true
                          ? _classIds.add(item.id)
                          : _classIds.remove(item.id),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Hủy'),
      ),
      FilledButton(
        onPressed: () {
          if (!_formKey.currentState!.validate()) return;
          final existing = widget.student;
          Navigator.pop(
            context,
            KarateStudent(
              id: existing?.id ?? 'VS${DateTime.now().millisecondsSinceEpoch}',
              name: _name.text.trim(),
              phone: _phone.text.trim(),
              belt: _belt,
              status: _status,
              classIds: _classIds.toList(),
              joinedAt: existing?.joinedAt ?? DateTime.now(),
            ),
          );
        },
        child: const Text('Lưu'),
      ),
    ],
  );
}

class _ClassDialog extends StatefulWidget {
  const _ClassDialog({this.karateClass});
  final KarateClass? karateClass;

  @override
  State<_ClassDialog> createState() => _ClassDialogState();
}

class _ClassDialogState extends State<_ClassDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _schedule;
  late final TextEditingController _coach;
  late final TextEditingController _location;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.karateClass?.name ?? '');
    _schedule = TextEditingController(text: widget.karateClass?.schedule ?? '');
    _coach = TextEditingController(text: widget.karateClass?.coach ?? '');
    _location = TextEditingController(text: widget.karateClass?.location ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _schedule.dispose();
    _coach.dispose();
    _location.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(
      widget.karateClass == null ? 'Tạo lớp Karate' : 'Sửa lớp Karate',
    ),
    content: SizedBox(
      width: 520,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(_name, 'Tên lớp *', required: true),
              _field(
                _schedule,
                'Lịch tập *',
                hint: 'Ví dụ: Thứ 2, 4, 6 · 17:30–19:00',
                required: true,
              ),
              _field(_coach, 'Huấn luyện viên'),
              _field(_location, 'Địa điểm'),
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Hủy'),
      ),
      FilledButton(
        onPressed: () {
          if (!_formKey.currentState!.validate()) return;
          Navigator.pop(
            context,
            KarateClass(
              id:
                  widget.karateClass?.id ??
                  'LH${DateTime.now().millisecondsSinceEpoch}',
              name: _name.text.trim(),
              schedule: _schedule.text.trim(),
              coach: _coach.text.trim(),
              location: _location.text.trim(),
            ),
          );
        },
        child: const Text('Lưu'),
      ),
    ],
  );

  Widget _field(
    TextEditingController controller,
    String label, {
    String? hint,
    bool required = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: controller,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(labelText: label, hintText: hint),
      validator: required
          ? (value) => value == null || value.trim().isEmpty
                ? 'Không được để trống'
                : null
          : null,
    ),
  );
}

class _AttendancePanel extends StatefulWidget {
  const _AttendancePanel({required this.model});
  final ClubViewModel model;

  @override
  State<_AttendancePanel> createState() => _AttendancePanelState();
}

class _AttendancePanelState extends State<_AttendancePanel> {
  String? _classId;
  final Set<String> _present = {};

  @override
  Widget build(BuildContext context) {
    final classes = widget.model.snapshot.classes;
    if (_classId != null && !classes.any((item) => item.id == _classId)) {
      _classId = null;
    }
    final students = _classId == null
        ? const <KarateStudent>[]
        : widget.model.snapshot.students
              .where((student) => student.classIds.contains(_classId))
              .toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Điểm danh hôm nay',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 14),
            if (classes.isEmpty)
              const Text('Hãy tạo lớp và xếp võ sinh trước khi điểm danh.')
            else ...[
              DropdownButtonFormField<String>(
                initialValue: _classId,
                decoration: const InputDecoration(labelText: 'Chọn lớp'),
                items: classes
                    .map(
                      (item) => DropdownMenuItem(
                        value: item.id,
                        child: Text(item.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() {
                  _classId = value;
                  _present.clear();
                }),
              ),
              if (_classId != null) ...[
                const SizedBox(height: 12),
                if (students.isEmpty)
                  const Text('Lớp này chưa có võ sinh.')
                else ...[
                  for (final student in students)
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _present.contains(student.id),
                      title: Text(student.name),
                      subtitle: Text(student.belt),
                      onChanged: (value) => setState(
                        () => value == true
                            ? _present.add(student.id)
                            : _present.remove(student.id),
                      ),
                    ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () async {
                        final ok = await widget.model.saveAttendance(
                          classId: _classId!,
                          date: DateTime.now(),
                          presentStudentIds: _present.toList(),
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                ok
                                    ? 'Đã lưu điểm danh.'
                                    : 'Không lưu được điểm danh.',
                              ),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Lưu điểm danh'),
                    ),
                  ),
                ],
              ],
            ],
            if (widget.model.snapshot.attendance.isNotEmpty) ...[
              const Divider(height: 30),
              Text('${widget.model.snapshot.attendance.length} buổi đã lưu'),
            ],
          ],
        ),
      ),
    );
  }
}

class _FinancePanel extends StatelessWidget {
  const _FinancePanel({required this.model});
  final ClubViewModel model;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Thu chi',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              FilledButton.icon(
                onPressed: () => _add(context),
                icon: const Icon(Icons.add),
                label: const Text('Giao dịch'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 18,
            runSpacing: 8,
            children: [
              _Money(
                label: 'Thu',
                value: model.income,
                color: Colors.green.shade700,
              ),
              _Money(
                label: 'Chi',
                value: model.expense,
                color: Colors.red.shade700,
              ),
              _Money(
                label: 'Số dư',
                value: model.balance,
                color: const Color(0xff403f44),
              ),
            ],
          ),
          if (model.snapshot.finances.isEmpty) ...[
            const SizedBox(height: 18),
            const Text('Chưa có giao dịch.'),
          ],
          for (final item in model.snapshot.finances.take(20)) ...[
            const Divider(height: 22),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: item.type == FinanceType.income
                    ? Colors.green.shade50
                    : Colors.red.shade50,
                child: Icon(
                  item.type == FinanceType.income
                      ? Icons.south_west
                      : Icons.north_east,
                  color: item.type == FinanceType.income
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                ),
              ),
              title: Text(item.category),
              subtitle: Text(
                '${_shortDate(item.date)}${item.note.isEmpty ? '' : ' · ${item.note}'}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${item.type == FinanceType.income ? '+' : '-'}${_currency(item.amount)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: item.type == FinanceType.income
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                    ),
                  ),
                  IconButton(
                    onPressed: () => model.deleteFinance(item.id),
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Xóa',
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ),
  );

  Future<void> _add(BuildContext context) async {
    final result = await showDialog<FinanceRecord>(
      context: context,
      builder: (_) => const _FinanceDialog(),
    );
    if (result != null) await model.addFinance(result);
  }
}

class _FinanceDialog extends StatefulWidget {
  const _FinanceDialog();

  @override
  State<_FinanceDialog> createState() => _FinanceDialogState();
}

class _FinanceDialogState extends State<_FinanceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _category = TextEditingController();
  final _note = TextEditingController();
  FinanceType _type = FinanceType.income;

  @override
  void dispose() {
    _amount.dispose();
    _category.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Thêm giao dịch'),
    content: Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SegmentedButton<FinanceType>(
              segments: const [
                ButtonSegment(
                  value: FinanceType.income,
                  label: Text('Thu'),
                  icon: Icon(Icons.south_west),
                ),
                ButtonSegment(
                  value: FinanceType.expense,
                  label: Text('Chi'),
                  icon: Icon(Icons.north_east),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (value) =>
                  setState(() => _type = value.first),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amount,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(labelText: 'Số tiền (VND) *'),
              validator: (value) => (int.tryParse(value ?? '') ?? 0) <= 0
                  ? 'Nhập số tiền lớn hơn 0'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _category,
              decoration: const InputDecoration(
                labelText: 'Nội dung *',
                hintText: 'Học phí, mua dụng cụ…',
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Vui lòng nhập nội dung'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _note,
              decoration: const InputDecoration(labelText: 'Ghi chú'),
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Hủy'),
      ),
      FilledButton(
        onPressed: () {
          if (!_formKey.currentState!.validate()) return;
          Navigator.pop(
            context,
            FinanceRecord(
              id: 'GD${DateTime.now().microsecondsSinceEpoch}',
              type: _type,
              amount: int.parse(_amount.text),
              category: _category.text.trim(),
              note: _note.text.trim(),
              date: DateTime.now(),
            ),
          );
        },
        child: const Text('Lưu'),
      ),
    ],
  );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.actionIcon,
    required this.onPressed,
  });
  final String title;
  final String actionLabel;
  final IconData actionIcon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(title, style: Theme.of(context).textTheme.headlineMedium),
      ),
      FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(actionIcon),
        label: Text(actionLabel),
      ),
    ],
  );
}

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value, this.icon);
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 260,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xffffdad6),
              child: Icon(icon, color: const Color(0xff8c1d18)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: Theme.of(context).textTheme.titleLarge),
                  Text(label),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    ),
  );
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({
    required this.icon,
    required this.title,
    required this.message,
  });
  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 44, color: Colors.grey[600]),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    ),
  );
}

class _InfoLine extends StatelessWidget {
  const _InfoLine(this.icon, this.text);
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text(text)),
      ],
    ),
  );
}

class _Money extends StatelessWidget {
  const _Money({required this.label, required this.value, required this.color});
  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: TextStyle(color: Colors.grey[700])),
      Text(
        _currency(value),
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    ],
  );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.model});
  final ClubViewModel model;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48),
          const SizedBox(height: 12),
          Text(model.error!, textAlign: TextAlign.center),
          const SizedBox(height: 14),
          FilledButton(onPressed: model.load, child: const Text('Thử lại')),
        ],
      ),
    ),
  );
}

Future<bool> _confirm(
  BuildContext context,
  String title,
  String message,
) async =>
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    ) ??
    false;

String _currency(int value) {
  final negative = value < 0;
  final digits = value.abs().toString();
  final result = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) result.write('.');
    result.write(digits[index]);
  }
  return '${negative ? '-' : ''}${result.toString()} ₫';
}

String _shortDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

String _dateLabel(DateTime date) =>
    'Ngày ${date.day} tháng ${date.month}, ${date.year}';
