# Decode Unicode – GTM Server-Side Variable Template

**Decode Unicode** is a custom **GTM Server-Side variable template** that decodes Unicode escape sequences (e.g., `\u00e4`) into human-readable characters. It’s ideal for working with encoded strings in incoming event payloads, such as product names, search terms, or user-generated content.

---

## 🧠 What It Does

This template scans a string for Unicode entities like `\\u00e4` and converts them to their character equivalents (`ä`, in this case). The decoding is done using `JSON.parse()` on the matched Unicode sequences.

---

## 📦 Use Cases

- Decode escaped Unicode in string values

## ⚙️ How to Use

You can install this template in two ways:

---

### 🔌 Option 1: Install via GTM Community Template Gallery

1. Open your **Server GTM container**.
2. Go to **Templates**.
3. Click **“Search Gallery”** in the top-right.
4. Search for **“Decode Unicode”**.
5. Click **Add**, review the permissions, and click **Save**.
6. Create a new variable using this template and select an input variable.

---

### 📥 Option 2: Manual Installation via Template File

1. In your **Server GTM container**, go to **Templates > New Variable Template**.
2. Click the **menu icon (⋮)** in the top-right and select **Import**.
3. Upload the `template.tpl` file from this repository.
4. Save the template as **“Decode Unicode”**.
5. Create a new variable using this template and select a variable as the input.
---

## 🔒 Required Permissions

This template uses the following built-in permissions:

- **`logging`**: For `logToConsole()` (debugging only)
- **`read_event_data`**: Access to event data via `getEventData()`

  ---

## 🙋‍♂️ Author

**Johan Björtin**  
https://github.com/Bjortin
