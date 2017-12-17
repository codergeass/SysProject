int main()
{
	int led=0x0001;
	int max=60000;
	int ratio=0;
	int state=0;
	int control=1;
	int delay1=0;
	int delay2=0;
	$0x0FFFFFC34=control;
	$0x0FFFFFC30=max;
	while(1>0)
	{
		if(state==0)
		{
			ratio=ratio+500;
		}
		if(state==1)
		{
			ratio=ratio-500;
		}
		if(ratio==60000)
		{
			state=1;
		}
		if(ratio==0)
		{
			state=0;
		}
		if(led==0x8000)
		{
			led=0x01;
		}
		else
		{
			led=led<<1;
		}
		$0xFFFFFC32=ratio;
		$0xFFFFFC60=led;
		while(delay1<=1000)
		{
			delay1=delay1+1;
			while(delay2<=1000)
			{
				delay2=delay2+1;
			}
			delay2=0;
		}
		delay1=0;
	}
	return 0;
}