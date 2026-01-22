# Google-Chrome Requirements- Vulnerability Remediation

1. **WQL Query** - For use in creating a dynamic device collection rule in the SCCM console
2. **SQL Query** - For direct validation against the SCCM database

**Target criteria:**
- Device must be a **Windows Server** (server-class OS)
- Device must have **Google Chrome** installed
- Uses standard SCCM hardware/software inventory views

---

## WQL Query (For SCCM Dynamic Collection)

```sql
SELECT SMS_R_System.ResourceId, SMS_R_System.ResourceType, SMS_R_System.Name, SMS_R_System.SMSUniqueIdentifier, SMS_R_System.ResourceDomainORWorkgroup, SMS_R_System.Client 
FROM SMS_R_System 
INNER JOIN SMS_G_System_ADD_REMOVE_PROGRAMS ON SMS_G_System_ADD_REMOVE_PROGRAMS.ResourceID = SMS_R_System.ResourceId 
WHERE SMS_R_System.OperatingSystemNameandVersion LIKE "%Server%" 
AND SMS_G_System_ADD_REMOVE_PROGRAMS.DisplayName LIKE "%Google Chrome%"
```

### What This Query Checks:
- **`SMS_R_System`** – The main system/device resource table
- **`SMS_G_System_ADD_REMOVE_PROGRAMS`** – Software inventory from Add/Remove Programs (32-bit applications)
- **`OperatingSystemNameandVersion LIKE "%Server%"`** – Filters to only Windows Server operating systems (e.g., "Windows Server 2019", "Windows Server 2022")
- **`DisplayName LIKE "%Google Chrome%"`** – Matches devices where Google Chrome appears in installed software

> **Note:** If Chrome is installed as a 64-bit application, you may also need to include `SMS_G_System_ADD_REMOVE_PROGRAMS_64` in your query:

```sql
SELECT SMS_R_System.ResourceId, SMS_R_System.ResourceType, SMS_R_System.Name, SMS_R_System.SMSUniqueIdentifier, SMS_R_System.ResourceDomainORWorkgroup, SMS_R_System.Client 
FROM SMS_R_System 
INNER JOIN SMS_G_System_ADD_REMOVE_PROGRAMS_64 ON SMS_G_System_ADD_REMOVE_PROGRAMS_64.ResourceID = SMS_R_System.ResourceId 
WHERE SMS_R_System.OperatingSystemNameandVersion LIKE "%Server%" 
AND SMS_G_System_ADD_REMOVE_PROGRAMS_64.DisplayName LIKE "%Google Chrome%"
```

---

## SQL Query (For Direct Database Validation)

```sql



UNION

SELECT DISTINCT 
    SYS.ResourceID,
    SYS.Name0 AS [Computer Name],
    SYS.Operating_System_Name_and0 AS [Operating System],
    ARP64.DisplayName0 AS [Software Name],
    ARP64.Version0 AS [Chrome Version]
FROM v_R_System SYS
INNER JOIN v_GS_ADD_REMOVE_PROGRAMS_64 ARP64 
    ON ARP64.ResourceID = SYS.ResourceID
WHERE SYS.Operating_System_Name_and0 LIKE '%Server%'
    AND ARP64.DisplayName0 LIKE '%Google Chrome%'

ORDER BY [Computer Name]
```

### What This Query Checks:
- **`v_R_System`** – SCCM view containing all discovered system resources
- **`v_GS_ADD_REMOVE_PROGRAMS`** – 32-bit software inventory view
- **`v_GS_ADD_REMOVE_PROGRAMS_64`** – 64-bit software inventory view
- **`UNION`** – Combines results from both 32-bit and 64-bit software registries
- **`DISTINCT`** – Prevents duplicate entries if Chrome appears in both views
- Returns computer name, OS, software name, and Chrome version for validation

---

## How to Use

### Creating the Dynamic Collection in SCCM:
1. Open the **SCCM Console**
2. Navigate to **Assets and Compliance** → **Device Collections**
3. Right-click and select **Create Device Collection**
4. Name it (e.g., "Servers with Google Chrome")
5. On the **Membership Rules** page, click **Add Rule** → **Query Rule**
6. Click **Edit Query Statement** → **Show Query Language**
7. Paste the WQL query and click OK

### Validating with SQL:
1. Open **SQL Server Management Studio**
2. Connect to your SCCM database (typically named `CM_<SiteCode>`)
3. Run the SQL query to verify which servers have Chrome installed

---

## Additional Considerations

| Consideration | Recommendation |
|---------------|----------------|
| **Software Inventory Timing** | Ensure hardware inventory has run recently on target servers |
| **Chrome Enterprise vs. Standard** | The `LIKE '%Google Chrome%'` pattern catches both editions |
| **Exact Match** | Use `= 'Google Chrome'` instead of `LIKE` if you need an exact match |
| **Collection Update Schedule** | Set an incremental update schedule for near-real-time membership |
