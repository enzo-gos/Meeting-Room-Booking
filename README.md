# GoMee

GoMee is web application that simplifies the process of reserving and managing meeting spaces within an organization at Golden Owl. It allows users to easily schedule, book, and manage meetings, check room availability in real-time, integrate with calendars, send automated notifications, track room utilization, and customize booking rules to align with organizational policies.
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
│           └── meeting_room_management_controller.rb
│   │   ├── concerns
│           ├── filterable.rb
│           └── google_calendar.rb
│   │   ├── users
│   │   ├── application_controller.rb
│   │   ├── dashboard_controller.rb
│   │   ├── meeting_rooms_controller.rb
│   │   ├── reservation_controller.rb
│   │   └── user_controller.rb
│   ├── helpers
│   │   ├── application_helper.rb
│   │   └── concerns
│   ├── jobs
│   ├── mailers
│   ├── models
│   │   └── concerns
│   ├── policies
│   ├── sidekiq
│   └── views
│       └── layouts
│           └── application.html.erb
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
   cd project-root
   ```

3. **Install dependencies:**

   ```bash
   bundle install
   ```

4. **Set up the database:**

   ```bash
   rails db:create
   rails db:migrate
   ```

5. **Set up environment variables:**

   - Create `.env` file in the project root.
   - Add required environment variables for Google OAuth, SendGrid, and other configurations.

6. **Run Sidekiq for background processing:**

   ```bash
   bundle exec sidekiq
   ```

7. **Run the server:**

   ```bash
   rails server
   ```

8. **Access the project:**
   Open a web browser and go to `http://localhost:3000` (or the specified port if different).

## Usage

Describe how to use the project, including any commands or actions users need to take.

## Contributing

If you'd like to contribute to this project, please follow these guidelines.

1. Fork the repository.
2. Create a new branch (`git checkout -b feature/fooBar`).
3. Make your changes.
4. Commit your changes (`git commit -am 'Add some fooBar'`).
5. Push to the branch (`git push origin feature/fooBar`).
6. Create a new Pull Request.

## License

This project is licensed under the [License Name] - see the [LICENSE](LICENSE) file for details.

---
