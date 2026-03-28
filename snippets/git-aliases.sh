

## 2. 代码片段（snippets/）

### `snippets/python-data-processing.py`

```python
#!/usr/bin/env python3
"""
数据处理常用工具函数
用于日常数据清洗和转换任务
"""

import json
import csv
from datetime import datetime
from typing import List, Dict, Any, Optional
import re


def flatten_dict(d: Dict, parent_key: str = '', sep: str = '_') -> Dict:
    """
    扁平化嵌套字典
    示例：{'a': {'b': 1}} -> {'a_b': 1}
    """
    items = []
    for k, v in d.items():
        new_key = f"{parent_key}{sep}{k}" if parent_key else k
        if isinstance(v, dict):
            items.extend(flatten_dict(v, new_key, sep=sep).items())
        else:
            items.append((new_key, v))
    return dict(items)


def parse_log_line(line: str) -> Optional[Dict[str, Any]]:
    """
    解析Nginx日志行
    返回结构化数据或None（如果格式不匹配）
    """
    pattern = r'(\S+) - - \[(.*?)\] "(\S+) (\S+) (\S+)" (\d{3}) (\d+)'
    match = re.match(pattern, line)
    
    if not match:
        return None
    
    ip, time_str, method, path, protocol, status, size = match.groups()
    
    return {
        'ip': ip,
        'timestamp': datetime.strptime(time_str, '%d/%b/%Y:%H:%M:%S %z'),
        'method': method,
        'path': path,
        'status': int(status),
        'size': int(size)
    }


def batch_process_csv(input_file: str, output_file: str, 
                     transform_fn, chunk_size: int = 1000):
    """
    分块处理大CSV文件，避免内存溢出
    """
    with open(input_file, 'r', encoding='utf-8') as f_in, \
         open(output_file, 'w', newline='', encoding='utf-8') as f_out:
        
        reader = csv.DictReader(f_in)
        fieldnames = reader.fieldnames
        writer = csv.DictWriter(f_out, fieldnames=fieldnames)
        writer.writeheader()
        
        batch = []
        for row in reader:
            batch.append(transform_fn(row))
            
            if len(batch) >= chunk_size:
                writer.writerows(batch)
                batch = []
                print(f"Processed {chunk_size} rows...")
        
        # 写入剩余数据
        if batch:
            writer.writerows(batch)
    
    print(f"Done! Output saved to {output_file}")


# 使用示例
if __name__ == "__main__":
    # 示例：清洗用户数据
    def clean_user_data(row: Dict) -> Dict:
        row['email'] = row['email'].lower().strip()
        row['phone'] = re.sub(r'\D', '', row.get('phone', ''))
        return row
    
    # batch_process_csv('raw_users.csv', 'clean_users.csv', clean_user_data)
    pass
