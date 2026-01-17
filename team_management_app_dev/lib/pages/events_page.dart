import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/event_card.dart';
import '../providers/event_provider.dart';
import '../data/models/team.dart';
import '../data/services/teams_service.dart';
import '../data/services/auth_service.dart';
import '../utils/constants.dart';
import '../widgets/custom_widgets.dart';
import '../utils/date_formatter.dart';

// EventsPage displays all events with filtering options
class EventsPage extends ConsumerStatefulWidget {
  const EventsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends ConsumerState<EventsPage> {
  String? selectedTeamFilter;
  List<Team> userTeams = [];
  bool loadingTeams = true;
  String dateRangeFilter = 'all'; // filters events by date range (all, today, week, month)

  @override
  void initState() {
    super.initState();
    _loadUserTeams(); // fetches teams on page load for dropdown filter
  }

  // retrieves teams from API and filters to user's teams
  Future<void> _loadUserTeams() async {
    try {
      final auth = AuthService();
      final token = auth.token;
      final userId = auth.userId;

      // fetches all teams from API
      final teamsService = TeamsService();
      final allTeams = await teamsService.fetchTeams(token);

      // filters to prevents showing unrelated teams in dropdown
      final filtered = allTeams
          .where(
            (team) => team.ownerId == userId || team.memberIds.contains(userId),
          )
          .toList();

      setState(() {
        userTeams = filtered;
        loadingTeams = false;
      });
    } catch (e) {
      print('error loading teams: $e');
      setState(() {
        loadingTeams = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // team filter dropdown
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border(
                bottom: BorderSide(color: AppColors.divider, width: 1),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                boxShadow: AppShadows.small,
              ),
              child: loadingTeams
                  ? const Padding(
                      padding: EdgeInsets.all(AppSpacing.sm),
                      child: Center(
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  : DropdownButton<String>(
                      value: selectedTeamFilter,
                      isExpanded: true,
                      hint: const Text('Filter by team'),
                      underline: Container(),
                      icon: const Icon(Icons.arrow_drop_down),
                      items: [
                        // all teams option
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Row(
                            children: [
                              Icon(Icons.group, size: 18, color: Colors.blue),
                              SizedBox(width: 8),
                              Text('All teams'),
                            ],
                          ),
                        ),
                        // real teams from api
                        ...userTeams.map((team) {
                          return DropdownMenuItem<String>(
                            value: team.name,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.group,
                                  size: 18,
                                  color: Colors.green,
                                ),
                                SizedBox(width: 8),
                                Text(team.name),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedTeamFilter = value;
                        });
                      },
                    ),
            ),
          ),

          // searchbar
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border(
                bottom: BorderSide(color: AppColors.divider, width: 1),
              ),
            ),
            child: TextField(
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).update(value);
              },
              decoration: InputDecoration(
                hintText: 'Search events...',
                hintStyle: AppTextStyles.body.copyWith(
                  color: AppColors.textHint,
                ),
                prefixIcon: Icon(Icons.search, color: AppColors.primary),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: BorderSide(color: AppColors.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // filter buttons
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border(
                bottom: BorderSide(color: AppColors.divider, width: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', 0),
                      const SizedBox(width: AppSpacing.xs),
                      _buildFilterChip('Upcoming', 1),
                      const SizedBox(width: AppSpacing.xs),
                      _buildFilterChip('Past', 2),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Date Range',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildDateRangeChip('All', 'all'),
                      const SizedBox(width: AppSpacing.xs),
                      _buildDateRangeChip('Today', 'today'),
                      const SizedBox(width: AppSpacing.xs),
                      _buildDateRangeChip('This Week', 'week'),
                      const SizedBox(width: AppSpacing.xs),
                      _buildDateRangeChip('This Month', 'month'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // list of events
          Expanded(child: _buildEventList()),
        ],
      ),
    );
  }

  // builds status filter chips
  Widget _buildFilterChip(String label, int index) {
    final selectedFilter = ref.watch(selectedFilterProvider);
    final bool isSelected = selectedFilter == index;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        ref.read(selectedFilterProvider.notifier).update(index);
      },
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surface,
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.divider,
        width: 1.5,
      ),
      labelStyle: AppTextStyles.bodySmall.copyWith(
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      checkmarkColor: Colors.white,
      elevation: isSelected ? AppSpacing.elevationSm : 0,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
    );
  }

  // builds date range filter chips 
  Widget _buildDateRangeChip(String label, String value) {
    final bool isSelected = dateRangeFilter == value;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        setState(() {
          dateRangeFilter = value;
        });
      },
      selectedColor: AppColors.accent,
      backgroundColor: AppColors.surface,
      side: BorderSide(
        color: isSelected ? AppColors.accent : AppColors.divider,
        width: 1.5,
      ),
      labelStyle: AppTextStyles.bodySmall.copyWith(
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      checkmarkColor: Colors.white,
      elevation: isSelected ? AppSpacing.elevationSm : 0,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
    );
  }

  // showing events in a list
  Widget _buildEventList() {
    final eventsData = ref.watch(filteredEventsProvider);

    return eventsData.when(
      // when loading
      loading: () => ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: 5,
        itemBuilder: (context, index) => const CardSkeleton(),
      ),

      // if error happens
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80, color: AppColors.error),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Oops! Something went wrong',
                style: AppTextStyles.h4,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                error.toString(),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.lg),
              AnimatedButton(
                onPressed: () {
                  ref.invalidate(eventsProvider);
                },
                backgroundColor: AppColors.primary,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.refresh),
                    SizedBox(width: AppSpacing.xs),
                    Text('Try Again', style: AppTextStyles.button),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // Success state
      data: (events) {
        // filter by team if selected
        var displayEvents = events;
        if (selectedTeamFilter != null) {
          // Find the selected team by name
          final selectedTeam = userTeams.firstWhere(
            (team) => team.name == selectedTeamFilter,
            orElse: () => userTeams.first,
          );

          // Filter events by teamId
          displayEvents = events.where((event) {
            return event.teamId == selectedTeam.id;
          }).toList();
        }

        // filter by date range
        if (dateRangeFilter != 'all') {
          displayEvents = displayEvents.where((event) {
            if (dateRangeFilter == 'today') {
              return DateFormatter.isToday(event.date);
            } else if (dateRangeFilter == 'week') {
              return DateFormatter.isThisWeek(event.date);
            } else if (dateRangeFilter == 'month') {
              return DateFormatter.isThisMonth(event.date);
            }
            return true;
          }).toList();
        }

        // Sort events by date and time 
        displayEvents.sort((a, b) {
          bool aIsUpcoming = a.type == 'upcoming';
          bool bIsUpcoming = b.type == 'upcoming';

          // Upcoming events first
          if (aIsUpcoming && !bIsUpcoming) return -1;
          if (!aIsUpcoming && bIsUpcoming) return 1;

          // Within same type, sort by date
          if (aIsUpcoming) {
            int dateComparison = a.date.compareTo(b.date);
            if (dateComparison != 0) return dateComparison;

            // If same date, sort by time (earliest first)
            return a.time.compareTo(b.time);
          } else {
            int dateComparison = b.date.compareTo(a.date);
            if (dateComparison != 0) return dateComparison;

            // If same date, sort by time (latest first for past events)
            return b.time.compareTo(a.time);
          }
        });

        // Show empty state if no events match
        if (displayEvents.isEmpty) {
          return EmptyState(
            icon: Icons.event_busy,
            title: 'No events found',
            message: events.isEmpty
                ? 'Create your first event to get started!\nOrganize training sessions, matches, and meetings.'
                : 'No events match your filters.\nTry adjusting the search or filters.',
          );
        }

        // showing events with fade-in animation
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(eventsProvider);
          },
          color: AppColors.primary,
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: displayEvents.length,
            itemBuilder: (context, i) {
              final event = displayEvents[i];

              // Fade-in animation for list items
              return TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 200 + (i * 50)),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 10 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: EventCard(
                  title: event.title,
                  date: DateFormatter.formatRelativeDate(event.date),
                  time: event.time,
                  location: event.location,
                  icon: EventTypeHelper.getIcon(event.iconType),
                  iconColor: EventTypeHelper.getColor(event.iconType),
                  onTap: () => _showEventDetails(event),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // showing event details when clicked
  void _showEventDetails(event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              EventTypeHelper.getIcon(event.iconType),
              color: EventTypeHelper.getColor(event.iconType),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(event.title, style: AppTextStyles.h5)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // date
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  DateFormatter.formatRelativeDate(event.date),
                  style: AppTextStyles.body,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            // time
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(event.time, style: AppTextStyles.body),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            // location
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(child: Text(event.location)),
              ],
            ),
            const SizedBox(height: 16),
            // description
            if (event.description.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(event.description),
              ),
          ],
        ),
        actions: [
          // delete button
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _confirmDelete(event);
            },
            icon: const Icon(Icons.delete, color: Colors.red),
            label: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
          // edit button
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _editEvent(event);
            },
            icon: const Icon(Icons.edit),
            label: const Text('Edit'),
          ),
          // close button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // confirming delete
  void _confirmDelete(event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event?'),
        content: Text('Are you sure you want to delete "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteEvent(event);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // deleting event
  Future<void> _deleteEvent(event) async {
    try {
      final repository = ref.read(eventRepositoryProvider);
      await repository.deleteEvent(event.id);

      // refresh list
      ref.invalidate(eventsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Event deleted! (Local mode - login needed to sync)',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // opening edit dialog
  void _editEvent(event) {
    showDialog(
      context: context,
      builder: (context) => _EditEventDialog(event: event),
    );
  }
}

// edit event dialog
class _EditEventDialog extends ConsumerStatefulWidget {
  final dynamic event;

  const _EditEventDialog({required this.event});

  @override
  ConsumerState<_EditEventDialog> createState() => _EditEventDialogState();
}

class _EditEventDialogState extends ConsumerState<_EditEventDialog> {
  late TextEditingController titleController;
  late TextEditingController locationController;
  late TextEditingController descriptionController;
  late DateTime selectedDate;
  late TimeOfDay selectedTime;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // pre-fill with existing data
    titleController = TextEditingController(text: widget.event.title);
    locationController = TextEditingController(text: widget.event.location);
    descriptionController = TextEditingController(
      text: widget.event.description,
    );
    selectedDate = widget.event.date;
    selectedTime = TimeOfDay(
      hour: widget.event.date.hour,
      minute: widget.event.date.minute,
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    locationController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Event'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // title
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // date picker
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  setState(() => selectedDate = picked);
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                ),
              ),
            ),
            const SizedBox(height: 16),

            // time picker
            InkWell(
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: selectedTime,
                );
                if (picked != null) {
                  setState(() => selectedTime = picked);
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Time',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.access_time),
                ),
                child: Text(selectedTime.format(context)),
              ),
            ),
            const SizedBox(height: 16),

            // location
            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 16),

            // description
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : _saveChanges,
          child: isLoading
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }

  // saving changes
  Future<void> _saveChanges() async {
    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Title required')));
      return;
    }

    setState(() => isLoading = true);

    try {
      final repository = ref.read(eventRepositoryProvider);

      // combine date and time
      final eventDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      // create updated event
      final updatedEvent = widget.event.copyWith(
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        date: eventDateTime,
        time: selectedTime.format(context),
        location: locationController.text.trim(),
        type: eventDateTime.isAfter(DateTime.now()) ? 'upcoming' : 'past',
      );

      await repository.updateEvent(widget.event.id, updatedEvent);

      // refresh
      ref.invalidate(eventsProvider);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event updated successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }
}
