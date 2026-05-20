<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class MedicalDataSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Chèn Bệnh (Diseases) - Mở rộng danh sách
        $diseases = [
            ['MaBenh' => 2, 'TenBenh' => 'Viêm phế quản cấp', 'MoTa' => 'Viêm nhiễm niêm mạc ống phế quản.', 'mabenhly' => 'J20'],
            ['MaBenh' => 3, 'TenBenh' => 'Sốt xuất huyết Dengue', 'MoTa' => 'Bệnh truyền nhiễm do virus Dengue.', 'mabenhly' => 'A90'],
            ['MaBenh' => 4, 'TenBenh' => 'Tăng huyết áp vô căn', 'MoTa' => 'Huyết áp cao không rõ nguyên nhân.', 'mabenhly' => 'I10'],
            ['MaBenh' => 5, 'TenBenh' => 'Đái tháo đường tuýp 2', 'MoTa' => 'Rối loạn chuyển hóa đường.', 'mabenhly' => 'E11'],
            ['MaBenh' => 6, 'TenBenh' => 'Viêm dạ dày cấp', 'MoTa' => 'Viêm niêm mạc dạ dày.', 'mabenhly' => 'K29'],
            ['MaBenh' => 7, 'TenBenh' => 'Sỏi thận', 'MoTa' => 'Sự lắng đọng chất khoáng trong thận.', 'mabenhly' => 'N20'],
            ['MaBenh' => 8, 'TenBenh' => 'Viêm đa khớp dạng thấp', 'MoTa' => 'Bệnh tự miễn gây viêm các khớp.', 'mabenhly' => 'M05'],
            ['MaBenh' => 9, 'TenBenh' => 'Rối loạn lo âu lan tỏa', 'MoTa' => 'Trạng thái lo âu kéo dài không rõ nguyên nhân.', 'mabenhly' => 'F41'],
            ['MaBenh' => 10, 'TenBenh' => 'Viêm tai giữa cấp', 'MoTa' => 'Nhiễm trùng tai giữa, thường gặp ở trẻ em.', 'mabenhly' => 'H66'],
            ['MaBenh' => 11, 'TenBenh' => 'Bệnh phổi tắc nghẽn mạn tính (COPD)', 'MoTa' => 'Hội chứng tắc nghẽn đường thở.', 'mabenhly' => 'J44'],
            ['MaBenh' => 12, 'TenBenh' => 'Viêm Gan B mạn tính', 'MoTa' => 'Nhiễm virus viêm gan B kéo dài trên 6 tháng.', 'mabenhly' => 'B18.1'],
            ['MaBenh' => 13, 'TenBenh' => 'Thoát vị đĩa đệm cột sống cổ', 'MoTa' => 'Đĩa đệm chệch khỏi vị trí gây chèn ép dây thần kinh.', 'mabenhly' => 'M50'],
            ['MaBenh' => 14, 'TenBenh' => 'Hội chứng ống cổ tay', 'MoTa' => 'Chèn ép dây thần kinh giữa tại cổ tay.', 'mabenhly' => 'G56.0'],
            ['MaBenh' => 15, 'TenBenh' => 'Gout', 'MoTa' => 'Viêm khớp do lắng đọng tinh thể acid uric.', 'mabenhly' => 'M10'],
        ];

        foreach ($diseases as $disease) {
            DB::table('benh')->updateOrInsert(['MaBenh' => $disease['MaBenh']], $disease);
        }

        // 2. Chèn Dịch vụ (Services) - Toàn diện hơn
        $services = [
            // Khoa Nội (MaKhoa 2)
            ['MaDichVu' => 8, 'TenDichVu' => 'Điện tâm đồ (ECG)', 'Gia' => 100000.00, 'MaKhoa' => 2, 'madichvuyte' => 'ECG_01'],
            ['MaDichVu' => 6, 'TenDichVu' => 'Nội soi dạ dày không đau', 'Gia' => 1200000.00, 'MaKhoa' => 2, 'madichvuyte' => 'NS_DADAY_ME'],
            ['MaDichVu' => 9, 'TenDichVu' => 'Nội soi đại tràng', 'Gia' => 1500000.00, 'MaKhoa' => 2, 'madichvuyte' => 'NS_DAITRANG'],
            
            // Khoa Xét nghiệm (MaKhoa 10)
            ['MaDichVu' => 2, 'TenDichVu' => 'Tổng phân tích tế bào máu ngoại vi', 'Gia' => 110000.00, 'MaKhoa' => 10, 'madichvuyte' => 'XN_HUYETHOC_01'],
            ['MaDichVu' => 3, 'TenDichVu' => 'Định lượng Glucose', 'Gia' => 45000.00, 'MaKhoa' => 10, 'madichvuyte' => 'XN_DUONG_HUYET'],
            ['MaDichVu' => 7, 'TenDichVu' => 'Tổng phân tích nước tiểu (10 thông số)', 'Gia' => 75000.00, 'MaKhoa' => 10, 'madichvuyte' => 'XN_NUOCTIEU_10'],
            ['MaDichVu' => 10, 'TenDichVu' => 'Định lượng Acid Uric', 'Gia' => 60000.00, 'MaKhoa' => 10, 'madichvuyte' => 'XN_URIC'],
            ['MaDichVu' => 11, 'TenDichVu' => 'Xét nghiệm chức năng Gan (ALAT, ASAT)', 'Gia' => 100000.00, 'MaKhoa' => 10, 'madichvuyte' => 'XN_GAN'],
            ['MaDichVu' => 12, 'TenDichVu' => 'Xét nghiệm chức năng Thận (Ure, Creatinin)', 'Gia' => 100000.00, 'MaKhoa' => 10, 'madichvuyte' => 'XN_THAN'],
            ['MaDichVu' => 13, 'TenDichVu' => 'Định lượng HbA1c', 'Gia' => 155000.00, 'MaKhoa' => 10, 'madichvuyte' => 'XN_HBA1C'],
            ['MaDichVu' => 14, 'TenDichVu' => 'XN tìm virus Viêm gan B (HBsAg)', 'Gia' => 130000.00, 'MaKhoa' => 10, 'madichvuyte' => 'XN_HBSAG'],
            ['MaDichVu' => 15, 'TenDichVu' => 'Xét nghiệm Lipid máu (Cholesterol, Triglycerid)', 'Gia' => 180000.00, 'MaKhoa' => 10, 'madichvuyte' => 'XN_MORO_MAU'],
            
            // Khoa Chẩn đoán hình ảnh (MaKhoa 11)
            ['MaDichVu' => 4, 'TenDichVu' => 'Siêu âm ổ bụng tổng quát', 'Gia' => 180000.00, 'MaKhoa' => 11, 'madichvuyte' => 'SA_BUNG'],
            ['MaDichVu' => 5, 'TenDichVu' => 'X-Quang ngực thẳng', 'Gia' => 140000.00, 'MaKhoa' => 11, 'madichvuyte' => 'XQ_NGUC'],
            ['MaDichVu' => 16, 'TenDichVu' => 'Siêu âm tuyến giáp', 'Gia' => 150000.00, 'MaKhoa' => 11, 'madichvuyte' => 'SA_GIAP'],
            ['MaDichVu' => 17, 'TenDichVu' => 'Siêu âm Doppler tim', 'Gia' => 450000.00, 'MaKhoa' => 11, 'madichvuyte' => 'SA_DOPPLER_TIM'],
            ['MaDichVu' => 18, 'TenDichVu' => 'Chụp CT-Scanner lồng ngực', 'Gia' => 1200000.00, 'MaKhoa' => 11, 'madichvuyte' => 'CT_NGUC'],
            ['MaDichVu' => 19, 'TenDichVu' => 'Chụp MRI cột sống cổ', 'Gia' => 2200000.00, 'MaKhoa' => 11, 'madichvuyte' => 'MRI_CO'],
            
            // Khoa Ngoại (MaKhoa 3)
            ['MaDichVu' => 20, 'TenDichVu' => 'Thay băng vết thương nhỏ', 'Gia' => 50000.00, 'MaKhoa' => 3, 'madichvuyte' => 'NGOAI_THAYBANG'],
            ['MaDichVu' => 21, 'TenDichVu' => 'Cắt chỉ vết thương', 'Gia' => 70000.00, 'MaKhoa' => 3, 'madichvuyte' => 'NGOAI_CATCHI'],
            
            // Khoa Nhi (MaKhoa 4) & Sản (MaKhoa 5)
            ['MaDichVu' => 22, 'TenDichVu' => 'Siêu âm thai 4D', 'Gia' => 350000.00, 'MaKhoa' => 5, 'madichvuyte' => 'SA_THAI_4D'],
            ['MaDichVu' => 23, 'TenDichVu' => 'Khám chuyên khoa Nhi', 'Gia' => 150000.00, 'MaKhoa' => 4, 'madichvuyte' => 'KB_NHI'],
        ];

        foreach ($services as $service) {
            DB::table('dichvu')->updateOrInsert(['MaDichVu' => $service['MaDichVu']], $service);
        }

        // 3. Mapping Dịch vụ - Bệnh (Phối hợp thực tế)
        $mapping = [
            // Cảm lạnh
            ['MaBenh' => 1, 'MaDichVu' => 1],
            
            // Viêm phế quản cấp
            ['MaBenh' => 2, 'MaDichVu' => 5], // X-Quang ngực
            ['MaBenh' => 2, 'MaDichVu' => 2], // XN máu
            
            // Sốt xuất huyết
            ['MaBenh' => 3, 'MaDichVu' => 2], 
            ['MaBenh' => 3, 'MaDichVu' => 5], 
            
            // Tăng huyết áp
            ['MaBenh' => 4, 'MaDichVu' => 8], // ECG
            ['MaBenh' => 4, 'MaDichVu' => 12], // XN chức năng thận
            ['MaBenh' => 4, 'MaDichVu' => 17], // Siêu âm tim
            
            // Đái tháo đường
            ['MaBenh' => 5, 'MaDichVu' => 3], // Glucose
            ['MaBenh' => 5, 'MaDichVu' => 13], // HbA1c
            ['MaBenh' => 5, 'MaDichVu' => 7], // Nước tiểu
            
            // Viêm dạ dày
            ['MaBenh' => 6, 'MaDichVu' => 6], // Nội soi
            ['MaBenh' => 6, 'MaDichVu' => 4], // Siêu âm bụng
            
            // Sỏi thận
            ['MaBenh' => 7, 'MaDichVu' => 4], // Siêu âm bụng
            ['MaBenh' => 7, 'MaDichVu' => 12], // XN chức năng thận
            ['MaBenh' => 7, 'MaDichVu' => 7], // XN nước tiểu
            
            // Gout
            ['MaBenh' => 15, 'MaDichVu' => 10], // Acid Uric
            ['MaBenh' => 15, 'MaDichVu' => 2], // XN máu
            
            // Viêm gan B
            ['MaBenh' => 12, 'MaDichVu' => 14], // HBsAg
            ['MaBenh' => 12, 'MaDichVu' => 11], // Chức năng gan
            ['MaBenh' => 12, 'MaDichVu' => 4],  // Siêu âm bụng
            
            // Thoát vị đĩa đệm
            ['MaBenh' => 13, 'MaDichVu' => 19], // MRI
        ];

        foreach ($mapping as $map) {
            DB::table('dichvu_benh')->updateOrInsert($map, $map);
        }
    }
}
