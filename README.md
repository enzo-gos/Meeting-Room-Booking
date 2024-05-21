# GoMeeting

GoMeeting is web application that simplifies the process of reserving and managing meeting spaces within an organization at Golden Owl. It allows users to easily schedule, book, and manage meetings, check room availability in real-time, integrate with calendars, send automated notifications, track room utilization, and customize booking rules to align with organizational policies.
<br />

# Table of Contents

- [Tech Stack](#techstack)
- [Features](#features)
- [Directory Structure](#directory-structure)
- [Setup Instructions](#setup-instructions)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)
  <br />
  <br />

# Architecture

![Architecture](https://github.com/enzo-gos/Meeting-Room-Booking/assets/164119335/273898cb-fb02-40e7-8ff8-478516b1b331)

# Tech Stack

| Category                   | Technology                          |
| -------------------------- | ----------------------------------- |
| Framework                  | Ruby on Rails 7                     |
| Language                   | Ruby 3.3                            |
| Database                   | PostgreSQL                          |
| Background Job             | Sidekiq                             |
| Google Services            | Google Calendar API + Google OAuth  |
| Error Monitoring           | Sentry                              |
| Email Delivery             | SendGrid                            |
| Authentication             | Devise + Omniauth (Google OAuth2.0) |
| Authorization & Permission | Pundit + Rolify                     |
| Template engine            | Slim                                |
| WYSIWYG                    | Trix Editor                         |
| Styling                    | Tailwind CSS                        |
| Icon Set                   | Material Icons                      |
| Testing                    | RSpec + Factory Bot + Faker         |

<br />

# Directory Structure

```
.
├── app
│   ├── assets
│   │   ├── config
│   │   ├── images
│   │   │   ├── avatar.png
│   │   │   ├── delete_icon.svg
│   │   │   ├── edit_icon.svg
│   │   │   ├── error_icon.svg
│   │   │   ├── google_icon.svg
│   │   │   └── info_icon.svg
│   │   └── stylesheets
│   │       ├── actiontext.css
│   │       ├── application.scss
│   │       ├── application.tailwind.css
│   │       └── flatpickr.css
│   ├── channels
│   │   ├── application_cable
│   │   │   ├── channel.rb
│   │   │   └── connection.rb
│   │   └── room_channel.rb
│   ├── controllers
│   │   ├── admin
│   │   │   ├── rooms_controller.rb
│   │   │   └── users_controller.rb
│   │   ├── concerns
│   │   │   ├── filterable.rb
│   │   │   └── google_calendar.rb
│   │   ├── users
│   │   ├── application_controller.rb
│   │   ├── dashboard_controller.rb
│   │   ├── meeting_rooms_controller.rb
│   │   ├── reservations_controller.rb
│   │   └── users_controller.rb
│   ├── helpers
│   │   ├── application_helper.rb
│   │   ├── dashboard_helper.rb
│   │   ├── meeting_rooms_helper.rb
│   │   ├── reservations_helper.rb
│   │   ├── schedules_helper.rb
│   │   ├── users_helper.rb
│   │   └── concerns
│   ├── javascript
│   │   ├── channels
│   │   ├── controllers
│   │   ├── helpers
│   │   ├── recurring_select
│   │   └── application.js
│   ├── jobs
│   ├── mailers
│   ├── models
│   │   ├── concerns
│   │   ├── application_record.rb
│   │   ├── department.rb
│   │   ├── facility.rb
│   │   ├── meeting_reservation.rb
│   │   ├── role.rb
│   │   ├── room.rb
│   │   ├── team.rb
│   │   └── user.rb
│   ├── policies
│   ├── sidekiq
│   │   ├── monthly_book_job.rb
│   │   ├── reservation_schedule_job.rb
│   │   └── send_event_job.rb
│   └── views
│       ├── active_storage
│       ├── admin
│       ├── book_scheduler_mailer
│       ├── dashboard
│       ├── devise
│       ├── layouts
│       ├── meeting_rooms
│       ├── reservations
│       └── user
├── bin
├── config
├── db
│   ├── migrate
│   ├── schema.rb
│   └── seeds.rb
├── lib
├── log
├── public
├── storage
├── test
├── tmp
└── vendor



```

## Setup Instructions

1. **Clone the repository:**

   ```bash
   git clone <repository-url>
   ```

2. **Navigate to the project directory:**

   ```bash
   cd Meeting-Room-Booking
   ```

3. **Install dependencies:**

   ```bash
   bundle install
   ```

4. **Set up the database:**

   ```bash
   rails db:setup
   ```

5. **Set up environment variables:**

   - Create `.env` file in the project root.
   - Add required environment variables for Google OAuth, SendGrid, and other configurations.

   ```bash
    GOOGLE_OAUTH_CLIENT_ID
    GOOGLE_OAUTH_CLIENT_SECRET

    MAIL_SERVICE_USERNAME
    MAIL_SERVICE_PASSWORD

    GOOGLE_CLIENT_ID
    GOOGLE_CLIENT_SECRET

    # Production
    MAIL_SERVICE_PRODUCTION
    MAIL_SERVICE_PORT_PRODUCTION
    MAIL_SERVICE_USERNAME_PRODUCTION
    MAIL_SERVICE_PASSWORD_PRODUCTION
   ```

6. **Run dev:**

   ```bash
   ./bin/dev
   ```

7. **Access the project:**
   Open a web browser and go to `http://localhost:3000` (or the specified port if different).

## License

This project is licensed under the [License Name] - see the [LICENSE](LICENSE) file for details.

---
