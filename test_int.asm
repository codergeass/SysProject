#################################################################################
#								Minisys_BIOS v0.1								
# 																				
#################################################################################

.data	0x0000								# 数据定义的首地址
		INT_TABLE	.word 0x000000CC			# 外部中断0	中断处理入口
		INT1		.word 0x000000E4			# 外部中断1	中断处理入口
		INT2		.word 0x00000100			# 外部中断2	中断处理入口
		INT3		.word 0x00000108			# 外部中断3	中断处理入口
		INT4		.word 0x00000110			# 外部中断4	中断处理入口
		INT5		.word 0x00000118			# 外部中断5	中断处理入口
		SYSC		.word 0x0000016C			# syscall 	异常处理入口
		BREK		.word 0x000001E4			# break 		异常处理入口
		UIMP		.word 0x000001f8			# 保留指令	异常处理入口
		PRIR		.word 0x00000200			# 特权级访问	异常处理入口
		OVFL		.word 0x00000208			# 加减溢出	异常处理入口
		DVZE		.word 0x00000210			# 除零		异常处理入口
					.space 0x00000010
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
# 定时器0
@INT0:		lui		$k0, 0xFFFF
			ori		$k0, $k0, 0xF000			# k0 接口地址高20位
			sw		$zero, 0x0C04($k0)		# 关闭数码管
			sw		$k0, 0x0C60($k0)			# 点亮led
			eret
# 定时器1
@INT1:		lui		$k0, 0xFFFF
			ori		$k0, $k0, 0xF000			# k0 接口地址高20位
			addi	$k1, $zero, 0xFF00
			sw		$k1, 0x0C04($k0)			# 显示数码管
			sw		$zero, 0x0C60($k0)		# 关闭led
			eret
# 未定义
@INT2:		eret
@INT3:		eret
@INT4:		eret
# 4x4键盘中断处理程序
@INT5:		lui		$k0, 0xFFFF
			ori		$k0, $k0, 0xF000			# k0 接口地址高20位
			lw		$k1, 0x0C12($k0)			# 读取键盘状态
			andi	$k1, $k1, 0x0001
			bgtz	$k1, @load5				# 如果有按键按下
	@end5:	eret
	@load5:	lw		$k1, 0x0C10($k0)			# 读取键盘键值
			lw		$k0, KEY_BUFF($zero)		# 键盘输入缓冲区指针
			addi	$k0, $k0, 0x0004			# +4
			andi	$k0, $k0, 0x007F			# 如果缓冲区满 [KEY_BUFF] = 0x0080
			bgtz	$k0, @full5 				# 则从缓冲区首地址重新开始
	@store5:sw		$k1, KEY_BUFF($k0)		# 存入键盘键值
			sw		$k0, KEY_BUFF($zero)		# 存入键盘输入缓冲区指针
			j		@end5					# 中断处理结束
	@full5:	addi	$k0, $zero, 0x0004		# [KEY_BUFF] = 0x0004
			j		@store5
# syscall
@sysc:		addi	$k0, $zero, 0x0001		# 
			beq		$k0, $v0, @Esys1			# 系统调用1
			addi	$k0, $zero, 0x0002		# 
			beq		$k0, $v0, @Esys2			# 系统调用2
			addi	$k0, $zero, 0x0003		# 
			beq		$k0, $v0, @Esys3			# 系统调用3
			addi	$k0, $zero, 0x0004		# 
			beq		$k0, $v0, @Esys3			# 系统调用4
			eret
	@Esys1:	jal		@DigiDisp
			eret
	@Esys2:	jal		@BuffDisp
			eret
	@Esys3:	jal		@chk_switch
			eret
	@Esys4:	jal		@light_led
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
# 临时变量：$t0

@DigiDisp:	addi	$t0, $zero, 0x0
			sw  		$a0, 0xfc00($t0)			# 低16位写入0xfffffc00
			addi	$t0, $zero ,0x2
			srl		$a0, $a0, 8				# 右移16位
			sw 		$a0, 0xfc00($t0)			# 高16位写入0xfffffc02
			addi	$t0, $zero, 0x4
			sw		$a1, 0xfc00($t0)			# 控制字写入0xfffffc04
			jr		$31						# 返回主调过程

# syscall 2
# 数码管显示输入缓冲区内最新的8个字（符）
#   若缓冲区指针小于8，则只显示0xc1-bp的字符。
#   缓冲区高地址字符（新字符）在数码管右侧（低位）
# 说明：输入缓冲区从0xc1到0x13c，0xc0为缓冲区指针bp，指针向高地址移动
# 传入参数：无
# 需要调用：上面的@DigiDisp:，使用参数a0、a1。
# 临时变量：$t0~$t3

@BuffDisp:	lw		$t0, 0xc0($zero)			# 读取缓冲区指针bp到$t0(bp>=4)
			addi	$t1, $t0,-32          	# t1 = bp - 32
			bltz	$t1, @LessThan8  	 	# if bp >= 32 then goto @LessThan8
# 若bp>=32，即缓冲区内字符不少于8个
@MoreThan8:	addi	$t1, $t0, -4           	# t1 = t0 - 4 移位位数
			lw 		$t2, 0xc0($t0)        	# t2 = buff[bp]
			sllv	$t2, $t2, $t1          	# t2 = t2 << t1
			or 		$a0, $a0, $t2          	# a0 = a0 | t2
			addi 	$t0, $t0, -4           	# t0 -= 4
			addi 	$t1, $t0, -4
			bgez 	$t1, @MoreThan8			# t0>=4 then goto @MoreThan8
			addi 	$a1, $zero, 0xff00     	# 数码管八位全开，小数点不显示
			j		@DigiDisp				# 进入显示子程序
@LessThan8: addi 	$t3, $zero, 0x0        	# t3(count) = 0
			addi 	$t2, $zero, 28         	# t2(const) = 28
			sub  	$t1, $t2, $t3          	# t1 = 28 - count
			lw   	$t2, 0xc0($t0)        	# t2 = buff[bp]
			sllv  	$t2, $t2, $t1          	# t2 = t2 << (28-count)
			or   	$a0, $a0, $t2          	# a0 = a0 | t2
			addi 	$t3, $t3, +4           	# count += 4
			addi 	$t0, $t0, -4           	# bp -= 4
			addi 	$t1, $t0, -4
			bgez 	$t1, @LessThan8       	# t0>=4 then goto @LessThan8
			sll  	$t3, $t3, 2				# count = count / 4
			addiu 	$a1, $zero, 0xffff
			addi 	$t1, $zero, 24
			sub  	$t1, $t1, $t3          	# t1 = 32 - count
			srlv 	$a1, $a1, $t3
			sllv 	$a1, $a1, $t3          	# 取高count位，控制数码管高count位点亮
			j    	@DigiDisp            		# 进入显示子程序

# syscall3
# 检查拨码开关状态
# 使用 $v1 作为返回值 返回当前拨码开关状态
@chk_switch:addi	$t0, $zero, 0x70
			lw  		$v1, 0xfc00($t0)			# 读取拨码开关状态
			jr		$31

# syscall4
# 点亮led
# 使用 $a0 作为参数
@light_led: addi		$t0, $zero, 0x60
			sw  		$a0, 0xfc00($t0)			# 读取拨码开关状态
			jr		$31


################################################################################
# 以下为BIOS初始化 开启中断 从内核态转到用户态 并调到用户程序地址
################################################################################

# BIOS初始化程序
@initial:	addiu	$t0, $zero, 0xFC11		# im:status[15:8] = 8'b11111100 
											# ksu:status[4:3] = 2'b10 ie:status[0] = 1'b1
			mtc0	$t0, $12					# 开中断并且切换到用户态
			j		@user_code				# 跳转到用户程序
# 用户程序
@user_code:	lui		$t0, 0xFFFF				# 让$28为0xFFFF0000作为端口地址的高16位
			ori		$gp, $t0,0xF000
			addi	$t3, $zero, 0x3210
			sw		$t3, 0xC00($gp)			# 数码管低四位数据
			addi	$t3, $zero, 0x7654
			sw		$t3, 0xC02($gp)			# 数码管高四位数据
			lw		$t1, NUM1($zero)			# 0x00000055
			lw		$t2, NUM2($zero)			# 0x000000AA
			add		$t3, $t1, $t2			# $1 = 0x000000FF
			sll		$t3, $t3, 8				# $1 = 0x0000FF00
			sw		$t3, 0xC04($gp)  		# 使能显示信号
			sw		$t3, 0xC20($gp)			# 喂看门狗
			addi 	$t0, $0, 0x0002 			# $2 = 0x00000002
			sw		$t0, 0xC20($gp)			# 定时器0设置为重复定时
			sw		$t0, 0xC22($gp)			# 定时器1设置为重复定时
			addiu	$t0, $zero, 0xFFF0		# $t0 = 0x0000FFF0
			sw		$t0, 0xCgp($gp)			# 定时器0设置初始值
			srl		$t0, $t0, 1				# 右移1位
			sw		$t0, 0xC2a($gp)			# 定时器1设置初始值
			sw		$t3, 0xC20($gp)			# 喂看门狗
			sll		$t2, $t2, 8				# 0x0000AA00
			sw		$t2, 0xC30($gp)			# PWM最大值
			srl		$t2, $t2, 8				# 0x000000AA
			sw		$t2, 0xC32($gp)			# PWM中间值
			addi 	$t2, $zero, 1 			# $2 = 0x00000001
			sw		$t2, 0xC34($gp)			# 使能PWM
	@wait:	lw		$t4, KEY_BUFF($zero)		# 获取键盘输入缓冲区指针
			sw		$t3, 0xC50($gp)			# 喂看门狗
			# addi 	$t0, $zero, 0x0004
			beq		$t4, $zero, @wait		# 有无输入
			jal		@BuffDisp				# 显示缓冲区数据
			j		@wait
	# @get:	lw		$t5, KEY_BUFF($t4)		# 获取键盘输入值
	# 		lw		$t6, 0xC00($gp)			# 获取数码管低四位数据
	# 		lw		$t7, 0xC02($gp)			# 获取数码管高四位数据
	# 		addi	$t4, $4, 0xFFFC			# -4
	# 		sw		$t4, KEY_BUFF($zero)		# 更新指针
	# 		sw		$t3, 0xC50($gp)			# 喂看门狗
	# 		sll		$t7, $t7, 16				# 左移16位
	# 		add		$t7, $t6, $t7			# 获取数码管八位数据
	# 		sll		$t7, $t7, 4				# 左移四位
	# 		add		$t7, $t5, $t7			# 加上输入键值
	# 		sw		$t7, 0xC00($gp)			# 数码管低四位数据
	# 		sw		$t3, 0xC50($gp)			# 喂看门狗
	# 		srl		$t7, $t7, 16				# 右移十六位
	# 		sw		$t7, 0xC02($gp)			# 数码管高四位数据
	# 		j		@wait					# 循环等待



