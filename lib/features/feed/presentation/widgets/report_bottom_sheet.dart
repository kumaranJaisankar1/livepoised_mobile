import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/report_controller.dart';

class ReportBottomSheet extends StatefulWidget {
  final dynamic contentId;
  final bool isPost;

  const ReportBottomSheet({
    super.key,
    required this.contentId,
    required this.isPost,
  });

  @override
  State<ReportBottomSheet> createState() => _ReportBottomSheetState();
}

class _ReportBottomSheetState extends State<ReportBottomSheet> {
  final ReportController controller = Get.put(ReportController());
  final List<String> reasons = [
    'Spam',
    'Hate speech or symbols',
    'Nudity or sexual activity',
    'Bullying or harassment',
    'False information',
    'Violence or dangerous organizations',
    'Intellectual property violation',
    'Suicide or self-injury',
    'Eating disorders',
    'Scam or fraud',
    'Drugs and regulated goods',
    'Something else',
  ];

  String? selectedReason;
  final TextEditingController descriptionController = TextEditingController();
  bool showDetails = false;
  bool isSuccess = false;

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isSuccess) ...[
            const SizedBox(height: 20),
            const Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
            const SizedBox(height: 24),
            Text(
              "Thanks for letting us know",
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              "Your report is another step towards making LivePoised a safer community for everyone. We'll review this content shortly.",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Done", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
          ] else ...[
            // Header
            Row(
              children: [
                Text(
                  showDetails ? "Add Details" : "Report ${widget.isPost ? 'Post' : 'Comment'}",
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),

            if (!showDetails) ...[
              Text(
                "Why are you reporting this ${widget.isPost ? 'post' : 'comment'}?",
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: reasons.length,
                  itemBuilder: (context, index) {
                    final reason = reasons[index];
                    return ListTile(
                      title: Text(reason),
                      trailing: const Icon(Icons.chevron_right, size: 20),
                      onTap: () {
                        setState(() {
                          selectedReason = reason;
                          showDetails = true;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    );
                  },
                ),
              ),
            ] else ...[
              Text(
                "Selected Reason: $selectedReason",
                style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Provide additional details (optional)...",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Your report is anonymous, except if you're reporting an intellectual property infringement.",
                style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value 
                    ? null 
                    : () async {
                        final success = await controller.submitReport(
                          contentId: widget.contentId,
                          isPost: widget.isPost,
                          reason: selectedReason!,
                          description: descriptionController.text,
                        );
                        if (success) {
                          setState(() => isSuccess = true);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: controller.isLoading.value
                    ? const SizedBox(
                        height: 20, 
                        width: 20, 
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      )
                    : const Text("Submit Report", style: TextStyle(fontWeight: FontWeight.bold)),
              )),
              TextButton(
                onPressed: () => setState(() => showDetails = false),
                child: const Text("Go Back"),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
