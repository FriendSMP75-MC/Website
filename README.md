# FriendSMP75 Website

Official website for the [FriendSMP75 Minecraft Server](https://discord.gg/K8ucVvjfge).

## Tech Stack

- Flutter Web (Dart) — frontend application
- go_router — client-side routing/navigation
- Supabase — authentication, database, and storage integration
- Python (Flask) — backend APIs for secure config, uploads, and data retrieval
- Vercel — deployment and pull request preview environments

## Code Structure

```text
lib/
	main.dart
	data/
		backend_config.dart
		supabase_config.dart
	router/
		app_router.dart
	pages/
		home.dart
		about.dart
		announcement.dart
		dashboard.dart
		gallery.dart
		status.dart
		support_us.dart
		votes.dart
		dashboards/
	sub_page/
		view_announcements.dart
	widgets/
		appbar.dart
		nav_drawer.dart
		footer.dart
		announcement_preview.dart

test/
	widget_test.dart
```

## Access Limitation

Local execution is not currently supported for external users/contributors due to private infrastructure and maintenance limitations.

This repository is kept for reference and internal maintenance.

## PR Preview

Changes can be reviewed through the Vercel Preview Deployment link attached to each pull request.

Even without local execution, reviewers can verify UI and behavior using that preview URL.

## Contribution Status

Contributions are welcome.

Because local execution is restricted for external contributors, all proposed changes should be reviewed using the Vercel Preview Deployment attached to each pull request.

Please keep pull requests focused, small, and clearly described.