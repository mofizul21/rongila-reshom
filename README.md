# Rongila Reshom - Inventory Management App

A comprehensive Flutter & Firebase inventory management application for "Rongila Reshom" clothing store.

## Features

### 1. **Authentication**
- Login with email/password
- Default admin: `admin@rongilareshom.com` / `123456`
- Admin can create new users (Manager role)
- Two roles: Admin (full access) and Manager (orders only)

### 2. **Products Management**
- Add products with title, purchase price, sale price, quantity, image URL, category, description
- View all products in grid layout
- Search products by title or description
- Edit and delete products
- **Duplicate products** for quick entry
- Low stock indicator

### 3. **Categories**
- Default categories: 3-piece, Sharee, Sit-kapor, Lungi, Others
- Add, edit, delete categories
- Assign products to categories

### 4. **Orders Management**
- Create orders with customer details (name, phone, address)
- Select multiple products per order
- Editable sale price per product
- Auto-calculate total amount and due amount
- Order status: Pending, Completed, Delivered
- Filter orders by status
- Search orders by customer name or phone
- Duplicate orders for quick reordering

### 5. **Customers Management**
- Add, edit, delete customers
- View customer order history
- Track total due amount per customer
- Search customers by name or phone

### 6. **Reports**
- Total Sales
- Total Purchase (Stock-in)
- Total Profit (Sales - Purchase Cost - Expenses)
- Total Due Collection
- Total Deposit
- Total Expenses
- Filter by date range

### 7. **Notes**
- Add, edit, delete notes
- Search notes by title or content

### 8. **User Management** (Admin only)
- View all users
- Change user roles (Admin/Manager)
- Register new users

### 9. **Payment History**
- View all payment records
- Filter by: All, Due, Paid
- Date-wise sorting
- Customer name, order date, amounts

### 10. **Suppliers**
- List all suppliers
- Add supplier with receipt image URL
- Track date and total amount
- Edit and delete suppliers

## Setup Instructions

### Prerequisites
- Flutter SDK (>=3.10.4)
- Firebase project
- Android Studio / VS Code

### 1. Clone and Install Dependencies
```bash
cd rongilareshom
flutter pub get
```

### 2. Firebase Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project
3. Enable **Authentication** (Email/Password)
4. Enable **Cloud Firestore** database
5. Add apps for your platforms (Web, Android, iOS)

### 3. Configure Firebase Options

Update `lib/services/firebase_options.dart` with your Firebase project credentials:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_API_KEY',
  appId: 'YOUR_APP_ID',
  messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
  projectId: 'YOUR_PROJECT_ID',
  authDomain: 'YOUR_AUTH_DOMAIN',
  storageBucket: 'YOUR_STORAGE_BUCKET',
);
```

### 4. Create Admin User

After setting up Firebase Authentication:
1. Run the app
2. Use the default credentials: `admin@rongilareshom.com` / `123456`
3. Or register a new admin user from the login screen

### 5. Firestore Security Rules

Set up Firestore security rules in Firebase Console:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 6. Run the App

```bash
# For Android
flutter run

# For iOS
flutter run

# For Web
flutter run -d chrome
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── app_user.dart
│   ├── product.dart
│   ├── category.dart
│   ├── order.dart
│   ├── customer.dart
│   ├── note.dart
│   ├── supplier.dart
│   └── expense.dart
├── services/                 # Firebase services
│   ├── auth_service.dart
│   ├── database_service.dart
│   └── firebase_options.dart
├── providers/                # State management (Provider)
│   ├── auth_provider.dart
│   ├── product_provider.dart
│   ├── category_provider.dart
│   ├── order_provider.dart
│   ├── customer_provider.dart
│   ├── note_provider.dart
│   ├── supplier_provider.dart
│   ├── expense_provider.dart
│   └── report_provider.dart
├── screens/                  # UI screens
│   ├── auth/
│   ├── products/
│   ├── categories/
│   ├── orders/
│   ├── customers/
│   ├── reports/
│   ├── notes/
│   ├── users/
│   ├── payments/
│   └── suppliers/
└── widgets/                  # Reusable widgets
    ├── app_theme.dart
    ├── common_widgets.dart
    ├── product_card.dart
    ├── order_card.dart
    └── customer_card.dart
```

## Technology Stack

- **Flutter** - UI Framework
- **Firebase** - Backend (Auth, Firestore)
- **Provider** - State Management
- **Google Fonts** - Typography
- **Intl** - Date/Number formatting
- **UUID** - Unique ID generation

## Default Categories

- 3-piece
- Sharee
- Sit-kapor
- Lungi
- Others (customizable)

## User Roles

### Admin
- Full access to all features
- Can create and manage users
- Can change user roles
- Access to Reports and User management

### Manager
- Can create and manage orders only
- Limited access to other features

## Profit Calculation

```
Profit = Total Sales - Total Purchase Cost - Total Expenses
```

## License

This project is proprietary software for Rongila Reshom.

## Support

For issues or questions, please contact the development team.
