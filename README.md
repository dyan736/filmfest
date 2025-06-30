# Film Festival Ticket Management - Admin Panel

Aplikasi admin panel untuk manajemen tiket film festival yang dibangun dengan Flutter dan Material 3 Design.

## 🎯 Fitur Utama

### 1. **Halaman Login Admin**
- Interface login yang elegan dengan Material 3 Design
- Validasi form dengan animasi loading
- Gradient background yang menarik
- Responsive design

### 2. **Dashboard Admin**
- **Statistik Real-time**: Total tiket, tiket terjual, pendapatan, dan jumlah pengguna
- **Grafik Interaktif**: 
  - Line chart untuk penjualan tiket 7 hari terakhir
  - Pie chart untuk status tiket (terjual, tersedia, habis)
- **Quick Actions**: Tombol akses cepat ke fitur utama
- **Navigation Rail**: Menu navigasi yang mudah digunakan

### 3. **Manajemen Tiket**
- **CRUD Operations**: Tambah, edit, hapus tiket
- **Status Tracking**: Monitor stok dan penjualan tiket
- **Search & Filter**: Cari tiket berdasarkan judul dan status
- **Progress Bar**: Visualisasi stok tiket yang tersisa
- **Dialog Forms**: Form yang user-friendly untuk input data

### 4. **Manajemen Pengguna**
- **User List**: Daftar semua pengguna terdaftar
- **User Management**: Edit, hapus, dan toggle status pengguna
- **User Statistics**: Informasi jumlah pesanan per pengguna
- **Search & Filter**: Cari pengguna berdasarkan nama dan status
- **Avatar Display**: Tampilan avatar dengan inisial nama

### 5. **Manajemen Pemesanan**
- **Order Tracking**: Monitor semua pemesanan tiket
- **Status Management**: Update status pembayaran dan pesanan
- **Order Details**: Detail lengkap setiap pesanan
- **Action Buttons**: Konfirmasi, batalkan, dan hapus pesanan
- **Payment Status**: Visual indicator untuk status pembayaran

### 6. **Scanner QR Code**
- **QR Scanner**: Scanner untuk validasi tiket
- **Manual Input**: Input kode tiket secara manual
- **Ticket Validation**: Verifikasi keaslian tiket
- **Scanner Overlay**: Interface scanner yang profesional
- **Result Display**: Tampilan hasil scan yang informatif

### 7. **Laporan & Analytics**
- **Multiple Report Types**: Pendapatan, penjualan tiket, pengguna, film populer
- **Period Selection**: Harian, mingguan, bulanan, tahunan
- **Interactive Charts**: Line chart dan bar chart yang responsif
- **Export Options**: Download laporan dalam format PDF dan Excel
- **Top Movies List**: Ranking film berdasarkan penjualan

### 8. **Pengaturan Sistem**
- **General Settings**: Mode gelap, bahasa, mata uang
- **Notification Settings**: Email dan push notification
- **Business Settings**: Pajak, maksimal tiket per pesanan
- **Payment Settings**: Metode pembayaran dan konfigurasi bank
- **System Settings**: Backup, reset, dan informasi aplikasi

## 🎨 Design Features

### Material 3 Design
- **Color Scheme**: Menggunakan Material 3 color system
- **Typography**: Consistent text hierarchy
- **Elevation**: Proper use of cards and shadows
- **Spacing**: Consistent padding dan margin
- **Icons**: Material Design icons yang konsisten

### Responsive Layout
- **Navigation Rail**: Side navigation untuk desktop
- **Grid Layout**: Responsive grid untuk dashboard
- **Card Design**: Consistent card layout
- **Mobile Friendly**: Optimized untuk berbagai ukuran layar

### User Experience
- **Loading States**: Indikator loading yang smooth
- **Error Handling**: Snackbar untuk feedback
- **Confirmation Dialogs**: Dialog konfirmasi untuk aksi penting
- **Form Validation**: Validasi input yang user-friendly

## 🛠️ Teknologi yang Digunakan

- **Flutter**: Framework utama
- **Material 3**: Design system
- **fl_chart**: Library untuk grafik dan chart
- **qr_flutter**: QR code generation
- **qr_code_scanner**: QR code scanning
- **pdf**: PDF generation untuk laporan
- **excel**: Excel export untuk laporan
- **shared_preferences**: Local storage
- **intl**: Internationalization

## 📱 Screenshots

### Login Screen
- Gradient background dengan card login
- Form validation dengan loading state
- Material 3 design elements

### Dashboard
- Statistik cards dengan warna yang kontras
- Interactive charts (line dan pie chart)
- Quick action buttons
- Navigation rail

### Ticket Management
- List view dengan progress bars
- Search dan filter functionality
- CRUD operations dengan dialogs
- Status indicators

### User Management
- User list dengan avatars
- Status badges
- Search functionality
- Action menus

### Order Management
- Order tracking dengan status indicators
- Payment status visualization
- Order details dialog
- Action buttons

### QR Scanner
- Scanner interface dengan overlay
- Manual input option
- Ticket validation
- Result display

### Reports
- Multiple chart types
- Period selection
- Export options
- Top movies ranking

### Settings
- Organized settings sections
- Interactive controls (switches, sliders, dropdowns)
- Payment method configuration
- System settings

## 🚀 Cara Menjalankan

1. **Clone repository**
   ```bash
   git clone <repository-url>
   cd film_fest_tiket
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run aplikasi**
   ```bash
   flutter run
   ```

## 📋 Requirements

- Flutter SDK 3.7.2 atau lebih tinggi
- Dart SDK 3.0.0 atau lebih tinggi
- Android Studio / VS Code
- Android SDK / iOS SDK (untuk testing)

## 🎯 Target Platform

- **Web**: Responsive web application
- **Desktop**: Windows, macOS, Linux
- **Mobile**: Android, iOS (dengan beberapa penyesuaian)

## 🔧 Konfigurasi

### Theme Configuration
```dart
ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF6750A4),
    brightness: Brightness.light,
  ),
  cardTheme: const CardTheme(
    elevation: 2,
    margin: EdgeInsets.all(8),
  ),
)
```

### Navigation
- Navigation Rail untuk desktop
- Bottom Navigation untuk mobile
- Consistent navigation patterns

## 📊 Data Structure

### Ticket Model
```dart
{
  'id': 'T001',
  'title': 'Avengers: Endgame',
  'date': '2024-01-15',
  'time': '19:00',
  'price': 75000,
  'stock': 50,
  'sold': 35,
  'status': 'active',
}
```

### User Model
```dart
{
  'id': 'U001',
  'name': 'John Doe',
  'email': 'john.doe@email.com',
  'phone': '+62 812-3456-7890',
  'joinDate': '2024-01-01',
  'status': 'active',
  'totalOrders': 5,
}
```

### Order Model
```dart
{
  'id': 'O001',
  'customerName': 'John Doe',
  'customerEmail': 'john.doe@email.com',
  'ticketTitle': 'Avengers: Endgame',
  'quantity': 2,
  'totalPrice': 150000,
  'orderDate': '2024-01-10',
  'showDate': '2024-01-15',
  'showTime': '19:00',
  'paymentStatus': 'paid',
  'orderStatus': 'confirmed',
}
```

## 🔮 Future Enhancements

- **Real-time Updates**: WebSocket untuk update real-time
- **Push Notifications**: Notifikasi untuk admin
- **Advanced Analytics**: Machine learning insights
- **Multi-language Support**: Internationalization
- **Dark Mode**: Toggle dark/light theme
- **Offline Support**: Offline data synchronization
- **Advanced Security**: Role-based access control
- **API Integration**: Backend API integration

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👥 Contributing

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📞 Support

Untuk pertanyaan atau dukungan, silakan hubungi:
- Email: admin@filmfestival.com
- Phone: +62 812-3456-7890

---

**Film Festival Ticket Management Admin Panel** - Built with ❤️ using Flutter & Material 3
