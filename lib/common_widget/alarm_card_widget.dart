import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../common/colo_extension.dart';
import '../../core/models/alarm_model.dart';
import '../../core/services/alarm_service.dart';
import '../../core/services/alarm_notification_service.dart';

class AlarmCardWidget extends StatefulWidget {
  final AlarmModel alarm;
  final VoidCallback? onAlarmUpdated;

  const AlarmCardWidget({
    super.key,
    required this.alarm,
    this.onAlarmUpdated,
  });

  @override
  State<AlarmCardWidget> createState() => _AlarmCardWidgetState();
}

class _AlarmCardWidgetState extends State<AlarmCardWidget> {
  bool _isLoading = false;
  late AlarmModel _currentAlarm; // Local copy to handle state updates

  @override
  void initState() {
    super.initState();
    _currentAlarm = widget.alarm;
    print('AlarmCardWidget initialized for alarm: ${_currentAlarm.id}, enabled: ${_currentAlarm.isEnabled}'); // Debug log
  }

  Future<void> _toggleAlarm() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      print('Toggling alarm ${_currentAlarm.id} from ${_currentAlarm.isEnabled} to ${!_currentAlarm.isEnabled}'); // Debug log
      final success = await AlarmService.toggleAlarm(
        _currentAlarm.id!,
        !_currentAlarm.isEnabled,
      );

      if (success && mounted) {
        setState(() {
          _currentAlarm = AlarmModel(
            id: _currentAlarm.id,
            userId: _currentAlarm.userId,
            alarmTime: _currentAlarm.alarmTime,
            title: _currentAlarm.title,
            isEnabled: !_currentAlarm.isEnabled, // Update the local state
            vibrate: _currentAlarm.vibrate,
            repeatDays: _currentAlarm.repeatDays,
            sound: _currentAlarm.sound,
            createdAt: _currentAlarm.createdAt,
          );
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _currentAlarm.isEnabled 
                ? 'Alarm enabled successfully'
                : 'Alarm disabled successfully',
            ),
            backgroundColor: TColor.primaryColor1,
          ),
        );

        // Notify parent to refresh
        widget.onAlarmUpdated?.call();
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to toggle alarm'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error toggling alarm: $e'); // Debug log
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteAlarm() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Alarm'),
        content: const Text('Are you sure you want to delete this alarm?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: TColor.gray),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              if (_isLoading) return;
              
              setState(() {
                _isLoading = true;
              });

              try {
                print('Deleting alarm: ${_currentAlarm.id}'); // Debug log
                final success = await AlarmService.deleteAlarm(_currentAlarm.id!);

                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Alarm deleted successfully'),
                      backgroundColor: TColor.primaryColor1,
                    ),
                  );
                  
                  // Notify parent to refresh
                  widget.onAlarmUpdated?.call();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to delete alarm'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                print('Error deleting alarm: $e'); // Debug log
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              } finally {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                }
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editAlarm() async {
    HapticFeedback.lightImpact();
    // TODO: Navigate to edit alarm screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit feature coming soon for "${_currentAlarm.title}"'),
        backgroundColor: TColor.primaryColor1,
      ),
    );
  }

  Future<void> _duplicateAlarm() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final duplicatedAlarm = AlarmModel(
        userId: _currentAlarm.userId,
        alarmTime: _currentAlarm.alarmTime,
        title: "${_currentAlarm.title} (Copy)",
        isEnabled: false, // Start disabled
        vibrate: _currentAlarm.vibrate,
        repeatDays: _currentAlarm.repeatDays,
        sound: _currentAlarm.sound,
        createdAt: DateTime.now(),
      );

      final createdAlarm = await AlarmService.createAlarm(duplicatedAlarm);
      
      if (createdAlarm != null && mounted) {
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Alarm "${createdAlarm.title}" created'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onAlarmUpdated?.call();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to duplicate alarm'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Building AlarmCardWidget for alarm: ${_currentAlarm.id}, enabled: ${_currentAlarm.isEnabled}'); // Debug log
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: TColor.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: TColor.gray.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Time display
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentAlarm.timeFormatted,
                  style: TextStyle(
                    color: TColor.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _currentAlarm.title,
                  style: TextStyle(
                    color: TColor.gray,
                    fontSize: 14,
                  ),
                ),
                if (_currentAlarm.repeatDays != null && 
                    _currentAlarm.repeatDays!.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    _currentAlarm.repeatDaysFormatted,
                    style: TextStyle(
                      color: TColor.primaryColor1,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Toggle switch
          Switch(
            value: _currentAlarm.isEnabled,
            onChanged: _isLoading ? null : (_) => _toggleAlarm(),
            activeThumbColor: TColor.primaryColor1,
            activeTrackColor: TColor.primaryColor1.withValues(alpha: 0.3),
          ),
          
          const SizedBox(width: 10),
          
          // Delete button
          IconButton(
            onPressed: _isLoading ? null : _deleteAlarm,
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.red,
              size: 20,
            ),
          ),
          
          // Vibration/Sound control button
          IconButton(
            onPressed: _isLoading ? null : () async {
              // Provide haptic feedback
              HapticFeedback.lightImpact();
              
              await AlarmNotificationService.toggleAlarmSound();
              setState(() {}); // Refresh to show updated state
              
              // Additional haptic feedback based on state
              if (AlarmNotificationService.isAlarmPlaying) {
                HapticFeedback.heavyImpact(); // Strong vibration when starting
              } else {
                HapticFeedback.mediumImpact(); // Medium vibration when stopping
              }
            },
            icon: Icon(
              AlarmNotificationService.isAlarmPlaying ? 
                Icons.volume_up : 
                Icons.volume_off,
              color: AlarmNotificationService.isAlarmPlaying ? 
                Colors.green : 
                Colors.grey,
              size: 20,
            ),
          ),
          
          // More options menu (3 dots)
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'delete':
                  _deleteAlarm();
                  break;
                case 'edit':
                  _editAlarm();
                  break;
                case 'duplicate':
                  _duplicateAlarm();
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 16, color: TColor.gray),
                    const SizedBox(width: 8),
                    Text('Edit Alarm', style: TextStyle(color: TColor.black)),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'duplicate',
                child: Row(
                  children: [
                    Icon(Icons.copy, size: 16, color: TColor.gray),
                    const SizedBox(width: 8),
                    Text('Duplicate', style: TextStyle(color: TColor.black)),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 16, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            child: Icon(
              Icons.more_vert,
              color: TColor.gray,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}