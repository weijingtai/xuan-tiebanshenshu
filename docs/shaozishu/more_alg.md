结合你现有**铁板神数代码**的迁移需求，我整理出：**常量数据表（JSON 格式，可直接嵌入代码）+ 全套算法伪代码（通用语法，可转 Python/Java/JS/C#）+ 函数替换对照表 + 边界规则 + 交叉差异标记**，所有逻辑严格对应前文邵子五大算法，区分和铁板的不同点，方便快速改造。

# 一、基础常量表（JSON）
可直接复制为配置文件/代码字典，**区分邵子专属、与铁板共用、铁板独有字段**
```json
{
  "note": "邵子神数 全套常量 | 标注【铁板不同】【共用】【铁板独有】",
  "1.邵子天干取数【铁板不同】": {
    "戊": 1,
    "乙": 2,
    "癸": 2,
    "庚": 3,
    "辛": 4,
    "壬": 6,
    "甲": 6,
    "丁": 7,
    "丙": 8,
    "己": 9
  },
  "2.邵子地支河图生成数【铁板不同】": {
    "子": [1, 6],
    "亥": [1, 6],
    "寅": [3, 8],
    "卯": [3, 8],
    "巳": [2, 7],
    "午": [2, 7],
    "申": [4, 9],
    "酉": [4, 9],
    "辰": [5, 10],
    "戌": [5, 10],
    "丑": [5, 10],
    "未": [5, 10]
  },
  "3.天地数基准【邵子独有，铁板无】": {
    "天数基准": 25,
    "地数基准": 30
  },
  "4.皇极天声数(天干)【邵子独有，铁板无】": {
    "甲": 1,
    "乙": 2,
    "丙": 3,
    "丁": 4,
    "戊": 5,
    "己": 6,
    "庚": 7,
    "辛": 8,
    "壬": 9,
    "癸": 10
  },
  "5.皇极地音数(地支)【邵子独有，铁板无】": {
    "子": 1,
    "丑": 2,
    "寅": 3,
    "卯": 4,
    "辰": 5,
    "巳": 6,
    "午": 7,
    "未": 8,
    "申": 9,
    "酉": 10,
    "戌": 11,
    "亥": 12
  },
  "6.先天八卦本数【与铁板完全共用】": {
    "乾": 1,
    "兑": 2,
    "离": 3,
    "震": 4,
    "巽": 5,
    "坎": 6,
    "艮": 7,
    "坤": 8
  },
  "7.三元九运寄宫规则【邵子独有，铁板无】": {
    "上元(1864-1923)": {
      "男": "艮",
      "女": "坤"
    },
    "中元(1924-1983)": {
      "阳男阴女": "艮",
      "阴男阳女": "坤"
    },
    "下元(1984-2043)": {
      "男": "艮",
      "女": "坤"
    }
  },
  "8.条文总量配置": {
    "邵子正统条文总数": 6144,
    "蠢子数条文总数": 1200,
    "铁板条文总数(参考)": 12000
  },
  "9.铁板独有常量(邵子直接删除)": [
    "太玄天干数",
    "太玄地支数",
    "时辰刻分表(一时8刻/一刻15分)",
    "考时定刻修正系数"
  ]
}
```

---

# 二、通用前置说明
## 输入统一格式
所有算法统一输入：`birth = (年干,年支,月干,月支,日干,日支,时干,时支, 出生年份, 性别, 阴阳)`
- 8 字：`年、月、日、时` 各一组干支
- 附加：公历出生年份、性别(男/女)、命造阴阳(阳/阴)

## 通用规则
1. 取模运算：**取余结果为 0 时，重置为基准最大值**（易学通用规则）
2. 邵子全系 **不使用时辰刻分**：代码中直接移除铁板「考时定刻」所有逻辑
3. 最终目标：算出**条文索引**，范围 `1 ~ 6144`

---

# 三、五大算法 完整伪代码（可直转代码）
## 算法1：河洛天地数取数法（邵子核心主算法）
> 核心差异：替换铁板「太玄数」，新增「天地数拆分、取余、三元寄宫」

```python
# 函数：calc_helo_tiandi(birth, config)
# 输入：birth八字、config=上方JSON常量
# 输出：最终条文号 1~6144
def calc_helo_tiandi(birth, config):
    # 1. 拆解八字
    year_g, year_z, month_g, month_z, day_g, day_z, hour_g, hour_z, birth_year, sex, yin_yang = birth
    gan_list = [year_g, month_g, day_g, hour_g]
    zhi_list = [year_z, month_z, day_z, hour_z]

    # 2. 天干转邵子数【替换铁板太玄天干函数】
    gan_nums = []
    tiangan_map = config["1.邵子天干取数【铁板不同】"]
    for g in gan_list:
        gan_nums.append(tiangan_map[g])

    # 3. 地支转河图双数【替换铁板太玄地支函数】
    zhi_nums = []
    dizhi_map = config["2.邵子地支河图生成数【铁板不同】"]
    for z in zhi_list:
        zhi_nums.extend(dizhi_map[z])

    # 4. 合并所有数字
    all_nums = gan_nums + zhi_nums

    # 5. 拆分 天数(奇数)、地数(偶数) 【邵子独有逻辑】
    tian_nums = [x for x in all_nums if x % 2 == 1]
    di_nums = [x for x in all_nums if x % 2 == 0]
    sum_tian = sum(tian_nums)
    sum_di = sum(di_nums)

    # 6. 计算天地余数 (取模，余数0=基准值)
    base_tian = config["3.天地数基准【邵子独有，铁板无】"]["天数基准"]  # 25
    base_di = config["3.天地数基准【邵子独有，铁板无】"]["地数基准"]    # 30
    rem_tian = sum_tian % base_tian
    rem_di = sum_di % base_di
    if rem_tian == 0:
        rem_tian = base_tian
    if rem_di == 0:
        rem_di = base_di

    # 7. 三元寄宫修正 【邵子独有，铁板无】
    ji_gong = ""
    # 判断三元区间
    if 1864 <= birth_year <= 1923:
        ji_gong = config["7.三元九运寄宫规则【邵子独有，铁板无】"]["上元(1864-1923)"][sex]
    elif 1924 <= birth_year <= 1983:
        key = "阳男阴女" if (sex=="男" and yin_yang=="阳") or (sex=="女" and yin_yang=="阴") else "阴男阳女"
        ji_gong = config["7.三元九运寄宫规则【邵子独有，铁板无】"]["中元(1924-1983)"][key]
    elif 1984 <= birth_year <= 2043:
        ji_gong = config["7.三元九运寄宫规则【邵子独有，铁板无】"]["下元(1984-2043)"][sex]
    # 寄宫赋值：艮=7 坤=8
    gong_num = 7 if ji_gong == "艮" else 8

    # 8. 计算本命基数
    base_num = (rem_tian * 8) + rem_di
    # 寄宫修正基数
    base_num = (base_num * gong_num) % 6144

    # 9. 映射为最终条文号 【6144条规则】
    article_num = base_num
    if article_num == 0:
        article_num = 6144
    return article_num
```

## 算法2：皇极声音唱和取数法（邵子本源，铁板完全无此逻辑）
```python
# 函数：calc_sheng_yin(birth, config)
# 输出：条文号 1~6144
def calc_sheng_yin(birth, config):
    year_g, year_z, month_g, month_z, day_g, day_z, hour_g, hour_z = birth[0:8]
    gan_list = [year_g, month_g, day_g, hour_g]
    zhi_list = [year_z, month_z, day_z, hour_z]

    # 1. 天干转天声数
    sheng_map = config["4.皇极天声数(天干)【邵子独有，铁板无】"]
    sheng_nums = [sheng_map[g] for g in gan_list]
    sum_sheng = sum(sheng_nums)
    sheng_he = sum_sheng % 10
    if sheng_he == 0:
        sheng_he = 10

    # 2. 地支转地音数
    yin_map = config["5.皇极地音数(地支)【邵子独有，铁板无】"]
    yin_nums = [yin_map[z] for z in zhi_list]
    sum_yin = sum(yin_nums)
    yin_he = sum_yin % 12
    if yin_he == 0:
        yin_he = 12

    # 3. 合数取64卦序号
    gua_seq = (sheng_he + yin_he) % 64
    if gua_seq == 0:
        gua_seq = 64

    # 4. 卦序映射条文：卦数 × 96
    article_num = gua_seq * 96
    return article_num
```

## 算法3：卦数+气数定命数法（六亲/寿元专用，共用八卦数，气数规则不同）
```python
# 函数：calc_gua_qi(birth, config)
# 依赖：先调用 calc_helo_tiandi 拿到天地余数
def calc_gua_qi(birth, config):
    # 1. 复用河洛法 拿到天余数、地余数
    rem_tian, rem_di = get_tiandi_remain(birth, config) # 抽取天地余数的子函数

    # 2. 取上下卦【与铁板共用先天八卦数】
    up_gua = rem_tian % 8
    down_gua = rem_di % 8
    if up_gua == 0:
        up_gua = 8
    if down_gua == 0:
        down_gua = 8

    # 3. 计算64卦序号
    gua_num = (up_gua - 1) * 8 + down_gua

    # 4. 计算气数【邵子独有：元会运世+节气+命宫 | 铁板=刻分+太玄】
    # 简化版气数（工程落地常用，完整版可扩展元会运世表）
    birth_year = birth[8]
    jieqi_num = get_jieqi_num(birth)    # 自定义：节气序号 1~24
    minggong_num = (ord(birth[0]) + ord(birth[1])) % 10 # 命宫数
    qi_num = (birth_year % 100) + jieqi_num + minggong_num

    # 5. 命数取模6144
    life_num = (gua_num * qi_num) % 6144
    article_num = 6144 if life_num == 0 else life_num
    return article_num
```

## 算法4：三元寄宫取数法（衍生算法，基于河洛法二次修正）
```python
# 函数：calc_sanyuan(birth, config)
# 本质 = 河洛天地数 + 强化寄宫修正
def calc_sanyuan(birth, config):
    # 先计算基础河洛条文号
    base_art = calc_helo_tiandi(birth, config)
    birth_year, sex = birth[8], birth[9]

    # 重新计算寄宫数
    if 1864 <= birth_year <= 1923 or 1984 <= birth_year <= 2043:
        gong = 7 if sex == "男" else 8
    else:
        yin_yang = birth[10]
        key = "阳男阴女" if (sex=="男" and yin_yang=="阳") or (sex=="女" and yin_yang=="阴") else "阴男阳女"
        gong = 7 if key == "阳男阴女" else 8

    # 二次修正
    final_num = (base_art * gong) % 6144
    return 6144 if final_num == 0 else final_num
```

## 算法5：蠢子数（邵子简化版，纯河洛、无寄宫、条文1200）
```python
# 函数：calc_chunzi(birth, config)
# 简化规则：去掉三元寄宫，条文总数1200
def calc_chunzi(birth, config):
    year_g, year_z, month_g, month_z, day_g, day_z, hour_g, hour_z = birth[0:8]
    gan_list = [year_g, month_g, day_g, hour_g]
    zhi_list = [year_z, month_z, day_z, hour_z]

    # 天干地支取数（同河洛）
    tiangan_map = config["1.邵子天干取数【铁板不同】"]
    dizhi_map = config["2.邵子地支河图生成数【铁板不同】"]
    gan_nums = [tiangan_map[g] for g in gan_list]
    zhi_nums = []
    for z in zhi_list:
        zhi_nums.extend(dizhi_map[z])

    all_nums = gan_nums + zhi_nums
    sum_tian = sum([x for x in all_nums if x%2==1])
    sum_di = sum([x for x in all_nums if x%2==0])

    # 天地余数
    rem_tian = sum_tian % 25 or 25
    rem_di = sum_di % 30 or 30

    # 无寄宫，直接计算基数
    base_num = rem_tian * 8 + rem_di
    # 映射 1~1200 条文
    art_num = base_num % 1200
    return 1200 if art_num == 0 else art_num
```

---

# 四、代码迁移对照表（铁板 → 邵子 增删改清单）
针对你现有**铁板神数代码**，按模块逐一调整，标注交叉/差异：

| 原铁板代码模块 | 操作方式 | 详细说明 |
| ---- | ---- | ---- |
| 太玄天干/地支取数函数 | **删除 + 替换** | 删掉整套太玄数逻辑，接入【邵子天干+河图地支】表 |
| 时辰、刻分、分钟计算函数 | **全部删除** | 邵子**无考时定刻**，这部分代码彻底移除 |
| 铁板条文映射（12000） | **修改常量** | 总数改为 6144，取模上限改为 6144 |
| 先天八卦取数函数 | **保留不动** | 两家规则完全一致，无需修改 |
| 天地数拆分、25/30取余 | **新增函数** | 铁板无此逻辑，单独封装成公共方法 |
| 十天声/十二地音计算 | **新增函数** | 铁板完全没有，独立实现声音唱和算法 |
| 三元九运、寄宫修正 | **新增函数** | 铁板无三元寄宫，单独实现 |
| 气数计算（刻分版） | **重构** | 删掉刻分逻辑，改为「元会运世+节气+命宫」 |
| 分支判断（铁板多门派） | **精简** | 邵子仅5套算法，删除铁板杂派分支 |

---

# 五、交叉复用说明（代码层面）
1. **可直接复用的公共函数**
   - 八卦名称 ↔ 数字转换
   - 干支合法性校验
   - 通用取模、边界修正（余数0重置为最大值）
2. **绝对不能复用的函数**
   - 太玄数换算
   - 时辰刻分解析
   - 铁板专属条文偏移量
3. **混合调用场景（邵子+铁板交叉查条文）**
   - 用邵子算法算出基数 → 做区间转换 → 调用现有铁板查表函数（补流年细节）
   - 用铁板卦数 → 转换为邵子天地余数 → 调用邵子六亲查表函数（补六亲断语）

---

# 六、补充工具子函数（通用抽取，减少冗余）
可把重复逻辑抽成公共方法，所有邵子算法共用：
```python
# 抽取天地余数（公共子函数）
def get_tiandi_remain(birth, config):
    # 内部逻辑同河洛法 2~6步，只返回 rem_tian, rem_di
    return rem_tian, rem_di

# 节气转数字（公共子函数）
def get_jieqi_num(birth):
    # 根据出生月日返回节气序号 1~24
    return jieqi_num
```