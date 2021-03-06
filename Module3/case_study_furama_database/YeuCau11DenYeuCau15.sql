use case_study_database;

-- YC11:Hiển thị thông tin các dịch vụ đi kèm đã được sử dụng bởi những khách hàng có ten_loai_khach là “Diamond” 
-- và có dia_chi ở “Vinh” hoặc “Quảng Ngãi”.
select dich_vu_di_kem.ma_dich_vu_di_kem,dich_vu_di_kem.ten_dich_vu_di_kem,khach_hang.ho_ten,khach_hang.dia_chi,loai_khach.ten_loai_khach
from dich_vu_di_kem inner join hop_dong_chi_tiet on hop_dong_chi_tiet.ma_dich_vu_di_kem = dich_vu_di_kem.ma_dich_vu_di_kem
inner join hop_dong on hop_dong_chi_tiet.ma_hop_dong = hop_dong.ma_hop_dong
inner join khach_hang on khach_hang.ma_khach_hang = hop_dong.ma_khach_hang 
inner join loai_khach on khach_hang.ma_loai_khach = loai_khach.ma_loai_khach
where loai_khach.ten_loai_khach = 'Diamond' and (khach_hang.dia_chi like '%Vinh%' or khach_hang.dia_chi like '%Quảng Ngãi%');

-- YC12:Hiển thị thông tin ma_hop_dong, ho_ten (nhân viên), ho_ten (khách hàng), so_dien_thoai (khách hàng), ten_dich_vu, so_luong_dich_vu_di_kem 
-- (được tính dựa trên việc sum so_luong ở dich_vu_di_kem), tien_dat_coc của tất cả các dịch vụ 
-- đã từng được khách hàng đặt vào 3 tháng cuối năm 2020 nhưng chưa từng được khách hàng đặt vào 6 tháng đầu năm 2021.
select hop_dong.ma_hop_dong,nhan_vien.ho_ten as ho_ten_nhan_vien,khach_hang.ho_ten as ho_ten_khach_hang,khach_hang.so_dien_thoai,dich_vu.ma_dich_vu,dich_vu.ten_dich_vu,
sum(ifnull(hop_dong_chi_tiet.so_luong,0)) as 'so_luong_dich_vu_di_kem',hop_dong.tien_dat_coc
from dich_vu_di_kem inner join hop_dong_chi_tiet on dich_vu_di_kem.ma_dich_vu_di_kem = hop_dong_chi_tiet.ma_dich_vu_di_kem
right join hop_dong on hop_dong.ma_hop_dong = hop_dong_chi_tiet.ma_hop_dong
right join dich_vu on hop_dong.ma_dich_vu = dich_vu.ma_dich_vu
right join khach_hang on khach_hang.ma_khach_hang = hop_dong.ma_khach_hang
right join nhan_vien on nhan_vien.ma_nhan_vien = hop_dong.ma_nhan_vien
where hop_dong.ma_hop_dong in 
(select hop_dong.ma_hop_dong from hop_dong where year(ngay_lam_hop_dong)=2020 and (month(ngay_lam_hop_dong) between 10 and 12))
and hop_dong.ma_hop_dong not in 
(select hop_dong.ma_hop_dong from hop_dong where year(ngay_lam_hop_dong)=2021 and (month(ngay_lam_hop_dong) between 1 and 6))
group by hop_dong.ma_hop_dong;

-- YC13:Hiển thị thông tin các Dịch vụ đi kèm được sử dụng nhiều nhất bởi các Khách hàng đã đặt phòng.
--  (Lưu ý là có thể có nhiều dịch vụ có số lần sử dụng nhiều như nhau).

select dich_vu_di_kem.ma_dich_vu_di_kem,dich_vu_di_kem.ten_dich_vu_di_kem,sum(ifnull(hop_dong_chi_tiet.so_luong,0)) as 'so_luong_dich_vu_di_kem'
from dich_vu_di_kem inner join hop_dong_chi_tiet on hop_dong_chi_tiet.ma_dich_vu_di_kem = dich_vu_di_kem.ma_dich_vu_di_kem
group by hop_dong_chi_tiet.ma_dich_vu_di_kem 
having sum(ifnull(hop_dong_chi_tiet.so_luong,0))>=(select max(hop_dong_chi_tiet.so_luong) from hop_dong_chi_tiet);

-- YC14:Hiển thị thông tin tất cả các Dịch vụ đi kèm chỉ mới được sử dụng một lần duy nhất. 
-- Thông tin hiển thị bao gồm ma_hop_dong, ten_loai_dich_vu, ten_dich_vu_di_kem, 
-- so_lan_su_dung (được tính dựa trên việc count các ma_dich_vu_di_kem).

select hop_dong.ma_hop_dong,dich_vu.ten_dich_vu,dich_vu_di_kem.ten_dich_vu_di_kem,count(dich_vu_di_kem.ma_dich_vu_di_kem) as 'so_lan_su_dung'
from dich_vu_di_kem inner join hop_dong_chi_tiet on hop_dong_chi_tiet.ma_dich_vu_di_kem = dich_vu_di_kem.ma_dich_vu_di_kem
inner join hop_dong on hop_dong.ma_hop_dong = hop_dong_chi_tiet.ma_hop_dong
inner join dich_vu on hop_dong.ma_dich_vu = dich_vu.ma_dich_vu
group by dich_vu_di_kem.ten_dich_vu_di_kem
having count(dich_vu_di_kem.ma_dich_vu_di_kem) = 1
order by ma_hop_dong;

-- YC15:Hiển thi thông tin của tất cả nhân viên bao gồm ma_nhan_vien, ho_ten, ten_trinh_do, ten_bo_phan, so_dien_thoai, dia_chi
--  mới chỉ lập được tối đa 3 hợp đồng từ năm 2020 đến 2021.

select nhan_vien.ma_nhan_vien,nhan_vien.ho_ten,trinh_do.ten_trinh_do,bo_phan.ten_bo_phan,
nhan_vien.so_dien_thoai,nhan_vien.dia_chi,count(hop_dong.ma_nhan_vien) as 'so_lan_lap_hop_dong'
from nhan_vien inner join trinh_do on nhan_vien.ma_trinh_do = trinh_do.ma_trinh_do
inner join bo_phan on nhan_vien.ma_bo_phan = bo_phan.ma_bo_phan
inner join hop_dong on hop_dong.ma_nhan_vien = nhan_vien.ma_nhan_vien
where year(hop_dong.ngay_lam_hop_dong) between 2020 and 2021
group by hop_dong.ma_nhan_vien
having count(hop_dong.ma_nhan_vien) <=3
order by hop_dong.ma_nhan_vien;

