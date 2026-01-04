SELECT
    SYS.Name0 AS 'Computer Name',
    LD.DeviceID0 AS 'Drive Letter',
    LD.FreeSpace0 / 1024 AS 'Free Space (MB)',
    LD.Size0 / 1024 AS 'Total Size (MB)'
FROM 
    v_GS_LOGICAL_DISK AS LD
JOIN 
    v_R_System AS SYS ON LD.ResourceID = SYS.ResourceID
WHERE 
    LD.DriveType0 = 3 -- Local Disk
    AND LD.FreeSpace0 < 13312 -- 13GB in MB
ORDER BY 
    LD.FreeSpace0 ASC
