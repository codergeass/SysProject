#################################################################################
#								Minisys_BIOS v0.1								#
# 																				#
#################################################################################

.data	0x0000								# 数据定义的首地址
		INT_TABLE	.word 0x000000D4			# 外部中断0	中断处理入口
		INT1		.word 0x000000DC			# 外部中断1	中断处理入口
		INT2		.word 0x000000E4			# 外部中断2	中断处理入口
		INT3		.word 0x000000EC			# 外部中断3	中断处理入口
		INT4		.word 0x000000F4			# 外部中断4	中断处理入口
		INT5		.word 0x0000012C			# 外部中断5	中断处理入口
		SYSC		.word 0x00000134			# syscall 	异常处理入口
		BREK		.word 0x000001C8			# break 		异常处理入口
		UIMP		.word 0x000001DC			# 保留指令	异常处理入口
		PRIR		.word 0x000001E4			# 特权级访问	异常处理入口
		OVFL		.word 0x000001EC			# 加减溢出	异常处理入口
		DVZE		.word 0x000001F4			# 除零		异常处理入口

		STAT		.word 0x00000000			# 用于定时器1调整PWM
					.space 0x0000000C
#.data	0x0040								# 堆栈区
		STACK_BUFF	.word 0x00000000
					.space 0x0000007C
#.data	0x00C0								# 键盘输入缓冲区
		KEY_BUFF	.word 0x00000000			# 键盘输入缓冲区指针
					.space 0x0000007C
#.data	0x0140
		USER_DATE	.word 0x00000000			# 用户数据段
		NUM1		.word 0x00000055
		NUM2		.word 0x000000AA

		# ...
         STATE .word 0x0
         RATIO .word 0x0
         KEY_FLAG .word 0x0
         LED_VALUE .word 0x0

.text	0x0000
@start:		j		@initial				# 跳转到初始化程序

#################################################################################
# 以下为异常中断处理程序
# 用户自定义中断处理时 根据需要 将中断处理程序地址存入 RAM 相应位置
# RAM 前六个地址对应六个中断处理程序地址 随后紧跟六个异常处理程序地址
#################################################################################

# 中断异常处理基地址
			mfc0	$k0, $13					# 读cp0原因寄存器 $13:CAUSE寄存器地址
			andi	$k1, $k0, 0x007C			# exc_code CAUSE[6:2]
			beq		$k1, $zero, @out_int		# 外部中断
			addi	$t0, $zero, 0x60			# 异常
			sw 		$k1, 0xfc00($t0)			# 点亮led 显示异常代码
			addi	$k1, $k1, 0xFFE8			# exc_code - 8
@chk_table:	lw		$k1, INT_TABLE($k1)		# 查中断向量表
			jr		$k1						# 跳转到相应中断处理程序
@out_int:	andi	$k1, $k0, 0xFC00			# ip[7:2] CAUSE[15:10]
			mfc0	$k0, $12					# 读cp0状态寄存器 $12:STATUS寄存器
			andi	$k0, $k0, 0xFC00			# im[7:2] STATUS[15:10]
			and		$k0, $k0, $k1			# im & ip
			srl		$k0, $k0, 10				# 对齐到地址低位
			andi	$k1, $k0, 0x0001			# IP[0]
			bgtz	$k1, @EInt0
			andi	$k1, $k0, 0x0002			# IP[1]
			bgtz	$k1, @EInt1
			andi	$k1, $k0, 0x0004			# IP[2]
			bgtz	$k1, @EInt2
			andi	$k1, $k0, 0x0008			# IP[3]
			bgtz	$k1, @EInt3
			andi	$k1, $k0, 0x0010			# IP[4]
			bgtz	$k1, @EInt4
			andi	$k1, $k0, 0x0020			# IP[5]
			bgtz	$k1, @EInt5
@EInt0:		addi	$k1, $zero, 0x00			# +0x0:External Int 0
			j		@chk_table
@EInt1:		addi	$k1, $zero, 0x04			# +0x4:External Int 1
			j		@chk_table
@EInt2:		addi	$k1, $zero, 0x08			# +0x8:External Int 2
			j		@chk_table
@EInt3:		addi	$k1, $zero, 0x0c			# +0xc:External Int 3
			j		@chk_table
@EInt4:		addi	$k1, $zero, 0x10			# +0x10:External Int 4
			j		@chk_table
@EInt5:		addi	$k1, $zero, 0x14			# +0x14:External Int 5
			j		@chk_table
# 未定义外部中断
@INT0:		eret
@INT1:		eret
@INT2:		eret
@INT3:		eret
@INT4:		lw   $t3,RATIO($zero)  # 读取PWM当前值
			addi $t2,$zero,0x01
			addi $t1,$zero,0x7fff
			sw   $t1,0xfc30($zero) # 写PWM最大值为32767
			sw   $t3,0xfc32($zero) # 写PWM对比值
			sw   $t2,0xfc34($zero) # 使能PWM
			addi $t3,$t3,0x100     # 当前值+512
			addi $t4,$t3,0x8ad0    # $t4 = $t3 - 30000
			bltz $t4,@T_I_RT			# $t3 <= 60000 则返回
			addi $t3,$zero,0x0     # $t3 >= 60000 则置0
@T_I_RT:	sw   $t3,RATIO($zero)  # PWM当前值写回
			eret
@INT5:		eret
# 4x4键盘中断处理程序
# @INT3:		lw		$k1, 0xFC02($zero)		# 获取数码管高四位数据
#	 		lw		$k0, 0xFC00($zero)		# 获取数码管低四位数据
#	 		sll		$k1, $k1, 16				# 左移16位
#	 		add		$k0, $k0, $k1			# 高低位相加
#	 		sll		$k0, $k0, 4
#			lw		$k1, 0xFC10($zero)		# 读取键盘键值
#			add		$k0, $k0, $k1
#			sw		$k0, 0xFC00($k0)			# 显示数码管低四位数据
#			srl		$k0, $k0, 16
#			sw		$k0, 0xFC02($k0)			# 显示数码管高四位数据
#			eret
#			lui		$k0, 0xFFFF
#			ori		$k0, $k0, 0xF000			# k0 接口地址高20位
#			lw		$k1, 0x0C12($k0)			# 读取键盘状态
#			andi	$k1, $k1, 0x0001
#			bgtz	$k1, @load3				# 如果有按键按下
#	@end3:	eret
#	@load3:	lw		$k1, 0x0C10($k0)			# 读取键盘键值
#			lw		$k0, KEY_BUFF($zero)		# 键盘输入缓冲区指针
#			addi	$k0, $k0, 0x0004			# +4
#			andi	$k0, $k0, 0x007F			# 如果缓冲区满 [KEY_BUFF] = 0x0080
#			bgtz	$k0, @full3				# 则从缓冲区首地址重新开始
#	@store3:sw		$k1, KEY_BUFF($k0)		# 存入键盘键值
#			sw		$k1, 0x0C60($k0)			# 点亮led (测试)
#			sw		$k0, KEY_BUFF($zero)		# 存入键盘输入缓冲区指针
#			j		@end3					# 中断处理结束
#	@full3:	addi	$k0, $zero, 0x0004		# [KEY_BUFF] = 0x0004
#			j		@store3
# 定时器0
# @INT4:		lui		$k0, 0xFFFF
#			ori		$k0, $k0, 0xF000			# k0 接口地址高20位
#			lw		$k1, 0x0C70($k0)			# 读取拨码开关状态
#			sw		$k1, 0x0C60($k0)			# 点亮led
#			eret
# 定时器1
# @INT5:		lw		$k0, STAT($zero)			# 获取当前状态
#			beq		$k0, $zero, @pwmadd
#	@pwm_:	lw		$k0, 0xFC32($zero)		# 读取PWM中间值
#			beq		$k0, $zero, @toadd
#			addi	$k0, $k0, -1
#			j		@end5
#	@toadd:	sw		$zero, STAT($zero)		# 变状态
#			addi	$k0, $zero, 1
#			j		@end5
#	@pwmadd:lw		$k0, 0xFC32($zero)		# 读取PWM中间值
#			lw		$k1, 0xFC30($zero)		# 读取PWM最大值
#			beq		$k0, $k1, @to_
#			addi	$k0, $k0, 1				# 中间值+1
#			j		@end5
#	@to_:	addi	$k1, $zero, 1
#			sw		$k1, STAT($zero)			# 变状态
#			addi	$k0, $k0, -1
#	@end5:	sw		$k0, 0xFC32($zero)		# 存中间值
#			eret
			# lui	$k0, 0xFFFF
			# ori	$k0, $k0, 0xF000			# k0 接口地址高20位
			# lw		$k1, 0x0C70($k0)			# 读取拨码开关状态
			# sw		$k1, 0x0C00($k0)			# 显示数码管
			# srl		$k1, $k1, 16
			# sw		$k1, 0x0C02($k0)			# 显示数码管
			# eret
# syscall
@sysc:		addi	$k0, $zero, 0x0001		# 
			beq		$k0, $v0, @Esys1			# 系统调用1
			addi	$k0, $zero, 0x0002		# 
			beq		$k0, $v0, @Esys2			# 系统调用2
			addi	$k0, $zero, 0x0003		# 
			beq		$k0, $v0, @Esys3			# 系统调用3
			addi	$k0, $zero, 0x0004		# 
			beq		$k0, $v0, @Esys4			# 系统调用4
			addi	$k0, $zero, 0x0005		# 
			beq		$k0, $v0, @Esys5			# 系统调用5
			eret
	@Esys1:	jal		@DigiDisp
			eret
	@Esys2:	jal		@KeyDisp
			eret
	@Esys3:	jal		@BuffDisp
			eret
	@Esys4:	jal		@chk_switch
			eret
	@Esys5:	jal		@light_led
			eret
# break
@brek:		mfc0	$k0, $14					# 获取EPC
			andi	$k0, $k0, 0x0004			# EPC加4
			mtc0	$k0, $14
			eret
# 保留指令
@uimp:		j		@BREK					# 同BREK
# 特权级访问
@prir:		j		@BREK					# 同BREK
# 加减溢出
@ofvl:		j		@BREK					# 同BREK
# 除零
@dvze:		j		@BREK					# 同BREK

#############################################################################
# 以下为BIOS系统调用
# 使用系统调用时 将系统调用号存入$v0寄存器 
# 相应系统调用所需参数存入$a0 $a1 $a2 $a3寄存器
#############################################################################

# syscall 1
# 数码管显示数字
# 传入参数：$a0 - 待显示的32位数值数据
#           	$a1 - 显示控制字（[15:8]位选，[7:0]小数点控制）
# 临时变量：$t7

@DigiDisp:	addi	$t7, $zero, 0x0
			sw  		$a0, 0xfc00($t7)			# 低16位写入0xfffffc00
			addi	$t7, $zero ,0x2
			srl		$a0, $a0, 8				# 右移16位
			sw 		$a0, 0xfc00($t7)			# 高16位写入0xfffffc02
			addi	$t7, $zero, 0x4
			sw		$a1, 0xfc00($t7)			# 控制字写入0xfffffc04
			jr		$31						# 返回主调过程

# syscall2 显示缓冲区最新数据到数码管最低位
# 数码管其它位数据左移
# 无调用参数 使用临时变量$t7 $t6 $t5

@KeyDisp:	lw		$t7, 0xFC02($zero)		# 获取数码管高四位数据
	 		lw		$t6, 0xFC00($zero)		# 获取数码管低四位数据
	 		sll		$t7, $t7, 16				# 左移16位
	 		add		$t7, $t7, $t6			# 高低位相加
			lw		$t6, KEY_BUFF($zero)		# 获取缓冲区指针
			lw		$t5, KEY_BUFF($t6)		# 获取最新数据
	 		sll		$t7, $t7, 4				# 左移四位
			add		$t7, $t5, $t7			# 相加
			sw		$t7, 0xFC00($zero)		# 存数码管低四位
			srl		$t7, $t7, 16				# 右移16位
			sw		$t7, 0xFC02($zero)		# 存数码管高四位
			jr		$31						# 返回

# syscall 3
# 数码管显示输入缓冲区内最新的8个字（符）
#   若缓冲区指针小于8，则只显示0xc1-bp的字符。
#   缓冲区高地址字符（新字符）在数码管右侧（低位）
# 说明：输入缓冲区从0xc1到0x13c，0xc0为缓冲区指针bp，指针向高地址移动
# 传入参数：无
# 需要调用：上面的@DigiDisp:，使用参数a0、a1。
# 临时变量：$t7 $t6 $t5 $t4

@BuffDisp:	lw		$t7, 0xc0($zero)			# 读取缓冲区指针bp到$t7(bp>=4)
			addi	$t6, $t7,-32          	# t6 = bp - 32
			bltz	$t6, @LessThan8  	 	# if bp >= 32 then goto @LessThan8
# 若bp>=32，即缓冲区内字符不少于8个
@MoreThan8:	addi	$t6, $t7, -4           	# t6 = t7 - 4 移位位数
			lw 		$t5, 0xc0($t7)        	# t5 = buff[bp]
			sllv	$t5, $t5, $t6          	# t5 = t5 << t6
			or 		$a0, $a0, $t5          	# a0 = a0 | t5
			addi 	$t7, $t7, -4           	# t7 -= 4
			addi 	$t6, $t7, -4
			bgez 	$t6, @MoreThan8			# t7>=4 then goto @MoreThan8
			addi 	$a1, $zero, 0xff00     	# 数码管八位全开，小数点不显示
			j		@DigiDisp				# 进入显示子程序
@LessThan8: addi 	$t4, $zero, 0x0        	# t4(count) = 0
			addi 	$t5, $zero, 28         	# t5(const) = 28
			sub  	$t6, $t5, $t4          	# t6 = 28 - count
			lw   	$t5, 0xc0($t7)        	# t5 = buff[bp]
			sllv  	$t5, $t5, $t6          	# t5 = t5 << (28-count)
			or   	$a0, $a0, $t5          	# a0 = a0 | t5
			addi 	$t4, $t4, +4           	# count += 4
			addi 	$t7, $t7, -4           	# bp -= 4
			addi 	$t6, $t7, -4
			bgez 	$t6, @LessThan8       	# t7>=4 then goto @LessThan8
			sll  	$t4, $t4, 2				# count = count / 4
			addiu 	$a1, $zero, 0xffff
			addi 	$t6, $zero, 24
			sub  	$t6, $t6, $t4          	# t6 = 32 - count
			srlv 	$a1, $a1, $t4
			sllv 	$a1, $a1, $t4          	# 取高count位，控制数码管高count位点亮
			j    	@DigiDisp            		# 进入显示子程序

# syscall4
# 检查拨码开关状态 使用 $t7
# 使用 $v1 作为返回值 返回当前拨码开关状态
@chk_switch:addi	$t7, $zero, 0x70
			lw  		$v1, 0xfc00($t7)			# 读取拨码开关状态
			jr		$31

# syscall5
# 点亮led
# 使用 $a0 作为参数 使用 $t7
@light_led: addi		$t7, $zero, 0x60
			sw  		$a0, 0xfc00($t7)			# 点亮led
			jr		$31


################################################################################
# 以下为BIOS初始化 开启中断 从内核态转到用户态 并调到用户程序地址
################################################################################

# BIOS初始化程序
@initial:	addiu	$t0, $zero, 0xFC11		# im:status[15:8] = 8'b11111100 
											# ksu:status[4:3] = 2'b10 ie:status[0] = 1'b1
			mtc0	$t0, $12					# 开中断并且切换到用户态
			# j		@user_code				# 跳转到用户程序

################################################################################
# 以下为用户程序
################################################################################


##########
# 主程序 #
##########
           # 设置流水灯初值
           addiu $s2,$zero,0x0001;
           sw   $s2,LED_VALUE($zero)

           # 设置占空比初值
           addiu $s2,$zero,0x0001;
           sw   $s2,RATIO($zero)

           # 开启定时器
           # 写cnt0方式寄存器-循环定时
           addi $s3,$zero,0x0002
           sw   $s3,0xfc20($zero)
           # 写cnt0初值寄存器
           addi $s3,$zero,0x7fff
           sw   $s3,0xfc28($zero)

           # 喂狗
@main:     addi $s6,$zero,0xffff
           sw   $s6,0xfc50($zero)
@func0:    lw   $s0,STATE($zero)
           addi $s1,$zero,0x0000
           bne  $s0,$s1,@func1
           # 喂狗
           addi $s6,$zero,0xffff
           sw   $s6,0xfc50($zero)
           # 数码管显示扫描键盘键值
           # 开始扫描键盘
           addi $s2,$zero,0x0       # s2清零
           # 等待按键
@wait_key: lw   $s2,0xfc12($zero)   # s2 <- flag
           lw   $s3,0xfc10($zero)   # s3 <- value
           addi $s6,$zero,0xffff
           sw   $s6,0xfc50($zero)   # 喂狗
           beq  $s2,$zero,@wait_key # 等待键值变化
           # 有键按下，清标记，写数码管
           addi $s2,$zero,0x0       # s2清零
           sw   $s3,0xfc00($zero)   # 键值写入数码管低位
           sw   $zero,0xfc02($zero) # 数码管高位写0
           addi $s2,$zero,0xff00
           sw   $s2,0xfc04($zero)   # 数码管全开

           j    @chk_swt

@func1:    lw   $s0,STATE($zero)
           addi $s1,$zero,0x0001
           bne  $s0,$s1,@func2
           # 喂狗
           addi $s6,$zero,0xffff
           sw   $s6,0xfc50($zero)
           # 关闭数码管
           sw   $zero,0xfc04($zero)
           # PWM小彩灯（呼吸灯）


           j    @chk_swt

@func2:    lw   $s0,STATE($zero)
           addi $s1,$zero,0x0002
           bne  $s0,$s1,@dflt
           # 喂狗
           addi $s6,$zero,0xffff
           sw   $s6,0xfc50($zero)
           # LED流水灯
           # 关闭数码管
           sw   $zero,0xfc04($zero)

           # 读取 LED_VALUE 并写入LED
           lw   $s2,LED_VALUE($zero)
           sw   $s2,0xfc60($zero)
           # 修改LED_VALUE
           lui  $s3,0x8000
           beq  $s2,$s3,@rst_ledv   # 若LED_VALUE==0x80000000则复位到1
           sll  $s2,$s2,1           # s2左移
           sw   $s2,LED_VALUE($zero)
           # 喂狗
           addi $s6,$zero,0xffff
           sw   $s6,0xfc50($zero)
           j    @chk_swt
@rst_ledv: addiu $s2,$zero,0x0001
           sw   $s2,LED_VALUE($zero)
           # 喂狗
           addi $s6,$zero,0xffff
           sw   $s6,0xfc50($zero)
           j    @chk_swt

           # 点亮led
@dflt:     lw   $s0,STATE($zero)
           sw   $s0,0xfc60($zero)
           # 喂狗
           addi $s6,$zero,0xffff
           sw   $s6,0xfc50($zero)

           # 读取拨码开关
@chk_swt:  lw   $s2,0xfc70($zero)
           sw   $s2,STATE($zero)
           # 点亮led
           lw   $s5,STATE($zero)
           sw   $s5,0xfc60($zero)
           # 喂狗
           addi $s6,$zero,0xffff
           sw   $s6,0xfc50($zero)
           j    @main
