结合你现有\*\*铁板神数代码\*\*的迁移需求，我整理出：\*\*常量数据表（JSON 格式，可直接嵌入代码）+ 全套算法伪代码（通用语法，可转 Python/Java/JS/C#）+ 函数替换对照表 + 边界规则 + 交叉差异标记\*\*，所有逻辑严格对应前文邵子五大算法，区分和铁板的不同点，方便快速改造。



\# 一、基础常量表（JSON）

可直接复制为配置文件/代码字典，\*\*区分邵子专属、与铁板共用、铁板独有字段\*\*

```json

{

&#x20; "note": "邵子神数 全套常量 | 标注【铁板不同】【共用】【铁板独有】",

&#x20; "1.邵子天干取数【铁板不同】": {

&#x20;   "戊": 1,

&#x20;   "乙": 2,

&#x20;   "癸": 2,

&#x20;   "庚": 3,

&#x20;   "辛": 4,

&#x20;   "壬": 6,

&#x20;   "甲": 6,

&#x20;   "丁": 7,

&#x20;   "丙": 8,

&#x20;   "己": 9

&#x20; },

&#x20; "2.邵子地支河图生成数【铁板不同】": {

&#x20;   "子": \[1, 6],

&#x20;   "亥": \[1, 6],

&#x20;   "寅": \[3, 8],

&#x20;   "卯": \[3, 8],

&#x20;   "巳": \[2, 7],

&#x20;   "午": \[2, 7],

&#x20;   "申": \[4, 9],

&#x20;   "酉": \[4, 9],

&#x20;   "辰": \[5, 10],

&#x20;   "戌": \[5, 10],

&#x20;   "丑": \[5, 10],

&#x20;   "未": \[5, 10]

&#x20; },

&#x20; "3.天地数基准【邵子独有，铁板无】": {

&#x20;   "天数基准": 25,

&#x20;   "地数基准": 30

&#x20; },

&#x20; "4.皇极天声数(天干)【邵子独有，铁板无】": {

&#x20;   "甲": 1,

&#x20;   "乙": 2,

&#x20;   "丙": 3,

&#x20;   "丁": 4,

&#x20;   "戊": 5,

&#x20;   "己": 6,

&#x20;   "庚": 7,

&#x20;   "辛": 8,

&#x20;   "壬": 9,

&#x20;   "癸": 10

&#x20; },

&#x20; "5.皇极地音数(地支)【邵子独有，铁板无】": {

&#x20;   "子": 1,

&#x20;   "丑": 2,

&#x20;   "寅": 3,

&#x20;   "卯": 4,

&#x20;   "辰": 5,

&#x20;   "巳": 6,

&#x20;   "午": 7,

&#x20;   "未": 8,

&#x20;   "申": 9,

&#x20;   "酉": 10,

&#x20;   "戌": 11,

&#x20;   "亥": 12

&#x20; },

&#x20; "6.先天八卦本数【与铁板完全共用】": {

&#x20;   "乾": 1,

&#x20;   "兑": 2,

&#x20;   "离": 3,

&#x20;   "震": 4,

&#x20;   "巽": 5,

&#x20;   "坎": 6,

&#x20;   "艮": 7,

&#x20;   "坤": 8

&#x20; },

&#x20; "7.三元九运寄宫规则【邵子独有，铁板无】": {

&#x20;   "上元(1864-1923)": {

&#x20;     "男": "艮",

&#x20;     "女": "坤"

&#x20;   },

&#x20;   "中元(1924-1983)": {

&#x20;     "阳男阴女": "艮",

&#x20;     "阴男阳女": "坤"

&#x20;   },

&#x20;   "下元(1984-2043)": {

&#x20;     "男": "艮",

&#x20;     "女": "坤"

&#x20;   }

&#x20; },

&#x20; "8.条文总量配置": {

&#x20;   "邵子正统条文总数": 6144,

&#x20;   "蠢子数条文总数": 1200,

&#x20;   "铁板条文总数(参考)": 12000

&#x20; },

&#x20; "9.铁板独有常量(邵子直接删除)": \[

&#x20;   "太玄天干数",

&#x20;   "太玄地支数",

&#x20;   "时辰刻分表(一时8刻/一刻15分)",

&#x20;   "考时定刻修正系数"

&#x20; ]

}

```



\---



\# 二、通用前置说明

\## 输入统一格式

所有算法统一输入：`birth = (年干,年支,月干,月支,日干,日支,时干,时支, 出生年份, 性别, 阴阳)`

\- 8 字：`年、月、日、时` 各一组干支

\- 附加：公历出生年份、性别(男/女)、命造阴阳(阳/阴)



\## 通用规则

1\. 取模运算：\*\*取余结果为 0 时，重置为基准最大值\*\*（易学通用规则）

2\. 邵子全系 \*\*不使用时辰刻分\*\*：代码中直接移除铁板「考时定刻」所有逻辑

3\. 最终目标：算出\*\*条文索引\*\*，范围 `1 \~ 6144`



\---



\# 三、五大算法 完整伪代码（可直转代码）

\## 算法1：河洛天地数取数法（邵子核心主算法）

> 核心差异：替换铁板「太玄数」，新增「天地数拆分、取余、三元寄宫」



```python

\# 函数：calc\_helo\_tiandi(birth, config)

\# 输入：birth八字、config=上方JSON常量

\# 输出：最终条文号 1\~6144

def calc\_helo\_tiandi(birth, config):

&#x20;   # 1. 拆解八字

&#x20;   year\_g, year\_z, month\_g, month\_z, day\_g, day\_z, hour\_g, hour\_z, birth\_year, sex, yin\_yang = birth

&#x20;   gan\_list = \[year\_g, month\_g, day\_g, hour\_g]

&#x20;   zhi\_list = \[year\_z, month\_z, day\_z, hour\_z]



&#x20;   # 2. 天干转邵子数【替换铁板太玄天干函数】

&#x20;   gan\_nums = \[]

&#x20;   tiangan\_map = config\["1.邵子天干取数【铁板不同】"]

&#x20;   for g in gan\_list:

&#x20;       gan\_nums.append(tiangan\_map\[g])



&#x20;   # 3. 地支转河图双数【替换铁板太玄地支函数】

&#x20;   zhi\_nums = \[]

&#x20;   dizhi\_map = config\["2.邵子地支河图生成数【铁板不同】"]

&#x20;   for z in zhi\_list:

&#x20;       zhi\_nums.extend(dizhi\_map\[z])



&#x20;   # 4. 合并所有数字

&#x20;   all\_nums = gan\_nums + zhi\_nums



&#x20;   # 5. 拆分 天数(奇数)、地数(偶数) 【邵子独有逻辑】

&#x20;   tian\_nums = \[x for x in all\_nums if x % 2 == 1]

&#x20;   di\_nums = \[x for x in all\_nums if x % 2 == 0]

&#x20;   sum\_tian = sum(tian\_nums)

&#x20;   sum\_di = sum(di\_nums)



&#x20;   # 6. 计算天地余数 (取模，余数0=基准值)

&#x20;   base\_tian = config\["3.天地数基准【邵子独有，铁板无】"]\["天数基准"]  # 25

&#x20;   base\_di = config\["3.天地数基准【邵子独有，铁板无】"]\["地数基准"]    # 30

&#x20;   rem\_tian = sum\_tian % base\_tian

&#x20;   rem\_di = sum\_di % base\_di

&#x20;   if rem\_tian == 0:

&#x20;       rem\_tian = base\_tian

&#x20;   if rem\_di == 0:

&#x20;       rem\_di = base\_di



&#x20;   # 7. 三元寄宫修正 【邵子独有，铁板无】

&#x20;   ji\_gong = ""

&#x20;   # 判断三元区间

&#x20;   if 1864 <= birth\_year <= 1923:

&#x20;       ji\_gong = config\["7.三元九运寄宫规则【邵子独有，铁板无】"]\["上元(1864-1923)"]\[sex]

&#x20;   elif 1924 <= birth\_year <= 1983:

&#x20;       key = "阳男阴女" if (sex=="男" and yin\_yang=="阳") or (sex=="女" and yin\_yang=="阴") else "阴男阳女"

&#x20;       ji\_gong = config\["7.三元九运寄宫规则【邵子独有，铁板无】"]\["中元(1924-1983)"]\[key]

&#x20;   elif 1984 <= birth\_year <= 2043:

&#x20;       ji\_gong = config\["7.三元九运寄宫规则【邵子独有，铁板无】"]\["下元(1984-2043)"]\[sex]

&#x20;   # 寄宫赋值：艮=7 坤=8

&#x20;   gong\_num = 7 if ji\_gong == "艮" else 8



&#x20;   # 8. 计算本命基数

&#x20;   base\_num = (rem\_tian \* 8) + rem\_di

&#x20;   # 寄宫修正基数

&#x20;   base\_num = (base\_num \* gong\_num) % 6144



&#x20;   # 9. 映射为最终条文号 【6144条规则】

&#x20;   article\_num = base\_num

&#x20;   if article\_num == 0:

&#x20;       article\_num = 6144

&#x20;   return article\_num

```



\## 算法2：皇极声音唱和取数法（邵子本源，铁板完全无此逻辑）

```python

\# 函数：calc\_sheng\_yin(birth, config)

\# 输出：条文号 1\~6144

def calc\_sheng\_yin(birth, config):

&#x20;   year\_g, year\_z, month\_g, month\_z, day\_g, day\_z, hour\_g, hour\_z = birth\[0:8]

&#x20;   gan\_list = \[year\_g, month\_g, day\_g, hour\_g]

&#x20;   zhi\_list = \[year\_z, month\_z, day\_z, hour\_z]



&#x20;   # 1. 天干转天声数

&#x20;   sheng\_map = config\["4.皇极天声数(天干)【邵子独有，铁板无】"]

&#x20;   sheng\_nums = \[sheng\_map\[g] for g in gan\_list]

&#x20;   sum\_sheng = sum(sheng\_nums)

&#x20;   sheng\_he = sum\_sheng % 10

&#x20;   if sheng\_he == 0:

&#x20;       sheng\_he = 10



&#x20;   # 2. 地支转地音数

&#x20;   yin\_map = config\["5.皇极地音数(地支)【邵子独有，铁板无】"]

&#x20;   yin\_nums = \[yin\_map\[z] for z in zhi\_list]

&#x20;   sum\_yin = sum(yin\_nums)

&#x20;   yin\_he = sum\_yin % 12

&#x20;   if yin\_he == 0:

&#x20;       yin\_he = 12



&#x20;   # 3. 合数取64卦序号

&#x20;   gua\_seq = (sheng\_he + yin\_he) % 64

&#x20;   if gua\_seq == 0:

&#x20;       gua\_seq = 64



&#x20;   # 4. 卦序映射条文：卦数 × 96

&#x20;   article\_num = gua\_seq \* 96

&#x20;   return article\_num

```



\## 算法3：卦数+气数定命数法（六亲/寿元专用，共用八卦数，气数规则不同）

```python

\# 函数：calc\_gua\_qi(birth, config)

\# 依赖：先调用 calc\_helo\_tiandi 拿到天地余数

def calc\_gua\_qi(birth, config):

&#x20;   # 1. 复用河洛法 拿到天余数、地余数

&#x20;   rem\_tian, rem\_di = get\_tiandi\_remain(birth, config) # 抽取天地余数的子函数



&#x20;   # 2. 取上下卦【与铁板共用先天八卦数】

&#x20;   up\_gua = rem\_tian % 8

&#x20;   down\_gua = rem\_di % 8

&#x20;   if up\_gua == 0:

&#x20;       up\_gua = 8

&#x20;   if down\_gua == 0:

&#x20;       down\_gua = 8



&#x20;   # 3. 计算64卦序号

&#x20;   gua\_num = (up\_gua - 1) \* 8 + down\_gua



&#x20;   # 4. 计算气数【邵子独有：元会运世+节气+命宫 | 铁板=刻分+太玄】

&#x20;   # 简化版气数（工程落地常用，完整版可扩展元会运世表）

&#x20;   birth\_year = birth\[8]

&#x20;   jieqi\_num = get\_jieqi\_num(birth)    # 自定义：节气序号 1\~24

&#x20;   minggong\_num = (ord(birth\[0]) + ord(birth\[1])) % 10 # 命宫数

&#x20;   qi\_num = (birth\_year % 100) + jieqi\_num + minggong\_num



&#x20;   # 5. 命数取模6144

&#x20;   life\_num = (gua\_num \* qi\_num) % 6144

&#x20;   article\_num = 6144 if life\_num == 0 else life\_num

&#x20;   return article\_num

```



\## 算法4：三元寄宫取数法（衍生算法，基于河洛法二次修正）

```python

\# 函数：calc\_sanyuan(birth, config)

\# 本质 = 河洛天地数 + 强化寄宫修正

def calc\_sanyuan(birth, config):

&#x20;   # 先计算基础河洛条文号

&#x20;   base\_art = calc\_helo\_tiandi(birth, config)

&#x20;   birth\_year, sex = birth\[8], birth\[9]



&#x20;   # 重新计算寄宫数

&#x20;   if 1864 <= birth\_year <= 1923 or 1984 <= birth\_year <= 2043:

&#x20;       gong = 7 if sex == "男" else 8

&#x20;   else:

&#x20;       yin\_yang = birth\[10]

&#x20;       key = "阳男阴女" if (sex=="男" and yin\_yang=="阳") or (sex=="女" and yin\_yang=="阴") else "阴男阳女"

&#x20;       gong = 7 if key == "阳男阴女" else 8



&#x20;   # 二次修正

&#x20;   final\_num = (base\_art \* gong) % 6144

&#x20;   return 6144 if final\_num == 0 else final\_num

```



\## 算法5：蠢子数（邵子简化版，纯河洛、无寄宫、条文1200）

```python

\# 函数：calc\_chunzi(birth, config)

\# 简化规则：去掉三元寄宫，条文总数1200

def calc\_chunzi(birth, config):

&#x20;   year\_g, year\_z, month\_g, month\_z, day\_g, day\_z, hour\_g, hour\_z = birth\[0:8]

&#x20;   gan\_list = \[year\_g, month\_g, day\_g, hour\_g]

&#x20;   zhi\_list = \[year\_z, month\_z, day\_z, hour\_z]



&#x20;   # 天干地支取数（同河洛）

&#x20;   tiangan\_map = config\["1.邵子天干取数【铁板不同】"]

&#x20;   dizhi\_map = config\["2.邵子地支河图生成数【铁板不同】"]

&#x20;   gan\_nums = \[tiangan\_map\[g] for g in gan\_list]

&#x20;   zhi\_nums = \[]

&#x20;   for z in zhi\_list:

&#x20;       zhi\_nums.extend(dizhi\_map\[z])



&#x20;   all\_nums = gan\_nums + zhi\_nums

&#x20;   sum\_tian = sum(\[x for x in all\_nums if x%2==1])

&#x20;   sum\_di = sum(\[x for x in all\_nums if x%2==0])



&#x20;   # 天地余数

&#x20;   rem\_tian = sum\_tian % 25 or 25

&#x20;   rem\_di = sum\_di % 30 or 30



&#x20;   # 无寄宫，直接计算基数

&#x20;   base\_num = rem\_tian \* 8 + rem\_di

&#x20;   # 映射 1\~1200 条文

&#x20;   art\_num = base\_num % 1200

&#x20;   return 1200 if art\_num == 0 else art\_num

```



\---



\# 四、代码迁移对照表（铁板 → 邵子 增删改清单）

针对你现有\*\*铁板神数代码\*\*，按模块逐一调整，标注交叉/差异：



| 原铁板代码模块 | 操作方式 | 详细说明 |

| ---- | ---- | ---- |

| 太玄天干/地支取数函数 | \*\*删除 + 替换\*\* | 删掉整套太玄数逻辑，接入【邵子天干+河图地支】表 |

| 时辰、刻分、分钟计算函数 | \*\*全部删除\*\* | 邵子\*\*无考时定刻\*\*，这部分代码彻底移除 |

| 铁板条文映射（12000） | \*\*修改常量\*\* | 总数改为 6144，取模上限改为 6144 |

| 先天八卦取数函数 | \*\*保留不动\*\* | 两家规则完全一致，无需修改 |

| 天地数拆分、25/30取余 | \*\*新增函数\*\* | 铁板无此逻辑，单独封装成公共方法 |

| 十天声/十二地音计算 | \*\*新增函数\*\* | 铁板完全没有，独立实现声音唱和算法 |

| 三元九运、寄宫修正 | \*\*新增函数\*\* | 铁板无三元寄宫，单独实现 |

| 气数计算（刻分版） | \*\*重构\*\* | 删掉刻分逻辑，改为「元会运世+节气+命宫」 |

| 分支判断（铁板多门派） | \*\*精简\*\* | 邵子仅5套算法，删除铁板杂派分支 |



\---



\# 五、交叉复用说明（代码层面）

1\. \*\*可直接复用的公共函数\*\*

&#x20;  - 八卦名称 ↔ 数字转换

&#x20;  - 干支合法性校验

&#x20;  - 通用取模、边界修正（余数0重置为最大值）

2\. \*\*绝对不能复用的函数\*\*

&#x20;  - 太玄数换算

&#x20;  - 时辰刻分解析

&#x20;  - 铁板专属条文偏移量

3\. \*\*混合调用场景（邵子+铁板交叉查条文）\*\*

&#x20;  - 用邵子算法算出基数 → 做区间转换 → 调用现有铁板查表函数（补流年细节）

&#x20;  - 用铁板卦数 → 转换为邵子天地余数 → 调用邵子六亲查表函数（补六亲断语）



\---



\# 六、补充工具子函数（通用抽取，减少冗余）

可把重复逻辑抽成公共方法，所有邵子算法共用：

```python

\# 抽取天地余数（公共子函数）

def get\_tiandi\_remain(birth, config):

&#x20;   # 内部逻辑同河洛法 2\~6步，只返回 rem\_tian, rem\_di

&#x20;   return rem\_tian, rem\_di



\# 节气转数字（公共子函数）

def get\_jieqi\_num(birth):

&#x20;   # 根据出生月日返回节气序号 1\~24

&#x20;   return jieqi\_num

```

