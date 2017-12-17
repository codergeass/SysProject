# 接口/外设控制API
.data 0x0050

.text 0x0000

# 数码管显示数字
# 传入参数：$a0 - 待显示的32位数值数据
#           $a1 - 显示控制字（[15:8]位选，[7:0]小数点控制）
# 临时变量：$t0

@DigiDisp:	addi $t0,$zero,0x0
			sw   $a0,0xfffffc00($t0)  # 低16位写入0xfffffc00
			addi $t0,$zero,0x2
			srl  $a0,$a0,8            # 右移16位
			sw   $a0,0xfffffc00($t0)  # 高16位写入0xfffffc02
			addi $t0,$zero,0x4
			sw   $a1,0xfffffc00($t0)  # 控制字写入0xfffffc04
			jr   $31                  # 返回主调过程

# 数码管显示输入缓冲区内最新的8个字（符）
#   若缓冲区指针小于8，则只显示0xc1-bp的字符。
#   缓冲区高地址字符（新字符）在数码管右侧（低位）
# 说明：输入缓冲区从0xc1到0x13c，0xc0为缓冲区指针bp，指针向高地址移动
# 传入参数：无
# 需要调用：上面的@DigiDisp:，使用参数a0、a1。
# 临时变量：$t0~$t3

@BuffDisp:	lw   $t0,0xc0($zero)      # 读取缓冲区指针bp到$t0(bp>=4)
			addi $t1,$t0,-32          # t1 = bp - 32
			bgez $t1,@LessThan8       # if bp >= 32 then goto @LessThan8
# 若bp>=32，即缓冲区内字符不少于8个
@MoreThan8:	addi $t1,$t0,-4           # t1 = t0 - 4 移位位数
			lw   $t2,0xc0($t0)        # t2 = buff[bp]
			sll  $t2,$t2,$t1          # t2 = t2 << t1
			or   $a0,$a0,$t2          # a0 = a0 | t2
			addi $t0,$t0,-4           # t0 -= 4
			addi $t1,$t0,-4
			bgez $t1,@MoreThan8       # t0>=4 then goto @MoreThan8
			addi $a1,$zero,0xff00     # 数码管八位全开，小数点不显示
			j    @DigiDisp            # 进入显示子程序
@LessThan8: addi $t3,$zero,0x0        # t3(count) = 0
			addi $t2,$zero,28         # t2(const) = 28
			sub  $t1,$t2,$t3          # t1 = 28 - count
			lw   $t2,0xc0($t0)        # t2 = buff[bp]
			sll  $t2,$t2,$t1          # t2 = t2 << (28-count)
			or   $a0,$a0,$t2          # a0 = a0 | t2
			addi $t3,$t3,+4           # count += 4
			addi $t0,$t0,-4           # bp -= 4
			addi $t1,$t0,-4
			bgez $t1,@MoreThan8       # t0>=4 then goto @LessThan8
			sll  $t3,$t3,2            # count = count / 4
			addiu $a1,$zero,0xffff
			addi $t1,$zero,24
			sub  $t1,$t1,$t3          # t1 = 32 - count
			srlv $a1,$a1,$t3
			sllv $a1,$a1,$t3          # 取高count位，控制数码管高count位点亮
			j    @DigiDisp            # 进入显示子程序
