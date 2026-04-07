# My API

A simple Rails API for order placement

---

## 🛠 Prerequisites

- **Ruby:** 2.7.8  
- **Rails:** 5.2.8.1  
- **Database:** PostgreSQL 14+ (or your preferred DB)

---

## ⚡ Setup Instructions

1. **Clone the repository:**

git clone https://github.com/Kylords/order-placement.git
cd order-placement


2. **Install dependencies:**

bundle install


3. **Setup the database:**

rails db:create
rails db:migrate


4. **Run the server:**

rails s


OTHERS:

To create an admin:
- Create a normal user using the frontend
- Promote the user via Rails console: **User.last.update!(role: 'admin')**


