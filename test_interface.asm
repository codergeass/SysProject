.data	0x0000						#数据定义的首地址
	NUM1	.word 0x00000055
	NUM2	.word 0x000000AA
	NUM3	.word 0x00000000
									#代码段定义开始
.text	0x0000						#代码开始的首地址
@start:lui	$1,0xFFFF				#让$28为0xFFFF0000作为端口地址的高16位
	ori	$28,$1,0xF000
	lw	$2,NUM1($0)
	lw	$3,NUM2($0)
	add $1,$2,$3						# $1 = 0x000000FF
	sw	$1, 0xC00($28)				# 显示数码管低四位
	sll	$1,$1,8						# $1 = 0x0000FF00
	sw	$1,0xC02($28)				# 显示数码管高四位
	sw 	$1,0xC04($28)  				# 使能显示信号
	sw	$2, 0xC50($28)				# 喂看门狗
	addi $2,$0,0xFFF0				# $2 = 0x0000FFF0
	sw	$2,0xC30($28)				# PWM最大值
	addi $2,$0,0x000A 				# $2 = 0x0000FFFA
	sw	$2,0xC32($28)				# PWM中间值
	addi $2,$0,1 					# $2 = 0x00000001
	sw	$2,0xC34($28)				# 使能PWM
@k1:addi $2,$0,2 					# $2 = 0x00000002
	sw	$2,0xC20($28)				# 定时器0设置为重复定时
	addi $2,$0,7 					# $2 = 0x00000007
	sw	$2,0xC24($28)				# 初始值为7
	sw	$2, 0xC50($28)				# 喂看门狗
	nop
	nop
@delay:or  $2,$zero,$zero
	lw  $2, 0xC12($28)				#读键盘状态
	ori  $1, $zero,1
	sw	$3, 0xC50($28)				#喂看门狗
	bne $2,$1, @delay				#没有键
	or  $2,$zero,$zero
	lw  $2, 0xC10($28)				#读键
	sw  $2, 0xC00($28)				#显示数码管低四位
	j	@delay
@gh:sub	$2,$2,$5					# $2 = 0x00000002
	sw	$2, 0xC50($28)				# 喂看门狗
	bne	$5,$2,@gh
	beq	$1,$1,@ty
	nop
@ty:jal	@jj
	j	@mm
@jj:jr	$31
@mm:addi $2,$0,0x99 					# $2 = 0x00000099
	ori	$3,$0,0x77 					# $3 = 0x00000077
	sll	$3,$2,4 						# $3 = 0x00000990
	srl	$3,$2,4 						# $3 = 0x00000009
	srlv $3,$2,$1 					
	lui	$6,0x9988
	sra	$7,$6,4
	addi $2,$0,0
	sw	$2, 0xC50($28)				# 喂看门狗
	addi $3,$0,2
	sub	$1,$2,$3
	j	@k1

.text 0xFFF8	
	jr	$26
.text 0xFFFC	
	jr	$27
