#!usr/bin/perl
my $configFile = $ARGV[0];
my $optrConfigFile = $ARGV[1];
die "the file $configFile is NOT exsit\n" if ( ! -e $configFile);
open FILE, "<$configFile";
my %config_for;
while (<FILE>) {
	if (/^(\w+)\s*=\s*(\w+)/) {
		$config_for{$1} = $2;
	}
}
close FILE;
if($optrConfigFile ne 'NONE'){
  die "the file $optrConfigFile is NOT exsit\n" if (! -e $optrConfigFile);
  open FILE, "<$optrConfigFile";
  while (<FILE>) {
        if (/^(\w+)\s*=\s*(\w+)/) {
                $config_for{$1} = $2;
        }
  }
  close FILE;
}

my $filedir = $ARGV[2];
my $write_filename = "$filedir/FeatureOption.java";
my $input_file = "mediatek/build/tools/javaoption.pm";
open(INPUT,$input_file) or die "can not open $input_file:$!\n";
my %javaoption;
while(<INPUT>)
{
	chomp;
	next if(/^\#/);
	next if(/^\s*$/);
	if(/\s*(\w+)\s*/)
	{
                if ($javaoption{$1} == 1)
                {
                        die "$1 already define in $input_file";
                } else {
                        push (@need_options,$1);
                        $javaoption{$1} = 1;
                }
        }
}


system("chmod u+w $write_filename") if (-e $write_filename);
system("mkdir -p $filedir") if ( ! -d "$filedir");
die "can NOT open $write_filename:$!" if ( ! open OUT_FILE, ">$write_filename");
print OUT_FILE "\/* generated by mediatek *\/\n\n";
print OUT_FILE "package com.mediatek.common.featureoption;\n";
print OUT_FILE "\npublic final class FeatureOption\n{\n";

#pre-parse dfo array start
my @dfoAll = ();
my @dfoSupport = split(/\s+/, $ENV{"DFO_NVRAM_SET"});
foreach my $dfoSet (@dfoSupport) {
    my $dfoSetName = $dfoSet."_VALUE";
    my @dfoValues = split(/\s+/, $ENV{"$dfoSetName"});
    foreach my $dfoValue (@dfoValues) {
        push(@dfoAll, $dfoValue);
    }
}

my @dfoArray = ();
foreach my $tempDfo (@dfoAll) {
    my $isFind = 0;
    #only eng load will enable dfo
    if ($ENV{"TARGET_BUILD_VARIANT"} ne "user" && $ENV{"TARGET_BUILD_VARIANT"} ne "userdebug") {
        foreach my $isDfoSupport (@dfoSupport) {
            if ($ENV{$isDfoSupport} eq "yes") {
                my $dfoSupportName = $isDfoSupport."_VALUE";
                my @dfoValues = split(/\s+/, $ENV{"$dfoSupportName"});
                foreach my $dfoValue (@dfoValues) {
                    if ($tempDfo eq $dfoValue) {
                        $isFind = 1;
                        break;
                    }
                }

                if ($isFind == 1) {
                    break;
                }
            }
        }
    }

    if ($isFind == 1) {
        push(@dfoArray, $tempDfo);
    }
}
my %dfoHashArray;
@dfoHashArray{@dfoArray} = ();
#print "Enable: @dfoArray\n";
#pre-parse dfo array end

foreach my $option (@need_options) {
    # if option is overrided by config.mk
    if ($option eq "MTK_DFO_RESOLUTION_SUPPORT")
    {
        if (exists $ENV{$option})
        {
            $config_for{$option} = $ENV{$option};
        }
    }
    # if option in  DFO_LIST THEN GEN FUNCTION CALL ELSE GEN AS NOMARL!
    if ($config_for{$option} eq "yes") {
        if (exists $dfoHashArray{$option}){
            &gen_java_file($write_filename, $option, "DynFeatureOption.getBoolean(\"$option\")", "boolean");
        } else {
            &gen_java_file($write_filename, $option, "true", "boolean");
        }
    }
    elsif ($config_for{$option} eq "no") {
        if (exists $dfoHashArray{$option}) {
            &gen_java_file ($write_filename, $option, "DynFeatureOption.getBoolean(\"$option\")", "boolean");
        } else {
            &gen_java_file ($write_filename, $option, "false", "boolean");
        }
    }
    elsif ($config_for{$option} =~/^[+-]?\d+$/)
    {
        if (exists $dfoHashArray{$option}) {
            &gen_java_file($write_filename,$option,"DynFeatureOption.getInt(\"$option\")", "int")
        } else {
            &gen_java_file($write_filename, $option, $config_for{$option}, "int");
        }
    }
    else
    {
		#add BUG_ID:JWLWKK-869 chenweihua 20140529 (start)
		if($option eq "RGK_SHOW_MOBILE_GROUP_SUPPORT") {
            &gen_java_file ($write_filename, $option, "false" , "boolean");
        }
		#add BUG_ID:JWLWKK-869 chenweihua 20140529 (end)
		#add BUG_ID:DLEL-358 chenweihua 20130809 (start)
		if($option eq "RGK_FAKE_SIGNAL_SUPPORT") {
            &gen_java_file ($write_filename, $option, "false" , "boolean");
        }
		#add BUG_ID:DLEL-358 chenweihua 20130809 (end)
		#add BUG_ID:JWLWKK-144 qinzhaojin 20140320 (start)
		if($option eq "RGK_RINGTONE_SETTING") {
            &gen_java_file ($write_filename, $option, "false" , "boolean");
        }
		#add BUG_ID:JWLWKK-144 qinzhaojin 20140320 (end)
        #add BUG_ID:JWLJ-156 chenshu 20140325 (start)
        if($option eq "RGK_DELIVERY_REPORT_SETTING") {
            &gen_java_file ($write_filename, $option, "false" , "boolean");
        }
        #add BUG_ID:JWLJ-156 chenshu 20140325 (end)
        #add BUG_id:JWLWKK-536 maoxinwei 20140331 (start)
        if($option eq "RGK_IP_DIAL") {
            &gen_java_file ($write_filename, $option, "false" , "boolean");
        }
        #add BUG_id:JWLWKK-536 maoxinwei 20140331 (end)
        #add BUG ID:JWLJ-151 chenshu 20140403 (start)
        if($option eq "RGK_DEFAULT_MOBILE_DATA_ENABLED") {
            &gen_java_file ($write_filename, $option, "false" , "boolean");
        }
        #add BUG ID:JWLJ-151 chenshu 20140403 (end)
    	#add BUG_ID:DELJ-94 chenweihua 20130929 (start)
    	if ($option eq "RGK_ALWAYS_SHOW_DATA_TYPE_SUPPORT") {
            &gen_java_file ($write_filename, $option, "true", "boolean");
        }
    	#add BUG_ID:DELJ-94 chenweihua 20130929 (end)
        #add JWLW-1312 chenweihua 20131107 (start)
        elsif ($option eq "RGK_FLY_MATCH_NUMBER_SUPPORT") {
            &gen_java_file ($write_filename, $option, "false", "boolean");
        }
        #add JWLW-1312 chenweihua 20131107 (end)
		#add BUG_ID:JWLJ-296 qianyadong 20140409(start)
        elsif ($option eq "RGK_DEFAULT_MYCARRIER") {
            &gen_java_file ($write_filename, $option, "false", "boolean");
        }
		#add BUG_ID:JWLJ-296 qianyadong 20140409(end)
		
		    #begin add by zhouzhuobin for JWLWKK-628 20140416
    elsif ($option eq "RGK_XOLO_SUPPORT") {
    	&gen_java_file ($write_filename, $option, "false", "boolean");
    }
    #end add by zhouzhuobin for JWLWKK-628 20140416

    #add BUG_id = JLLB-146 yb 20140428 (start)
        elsif ($option eq "RGK_XOLO_ECC") {
    	    &gen_java_file ($write_filename, $option, "false", "boolean");
        }    
    #add BUG_id = JLLB-146 yb 20140428 (end)
    
	#add BUG ID:JWLJ-297 chenshu 20140418 (start)
        elsif ($option eq "RGK_ENABLE_VCALENDAR") {
    	    &gen_java_file ($write_filename, $option, "true", "boolean");
        }
        #add BUG ID:JWLJ-297 chenshu 20140418 (end)
		#add BUG ID:JBLWKK-33 chenshu 20140520 (start)
        elsif ($option eq "RGK_SMS_ENCODING_LOSSY") {
    	    &gen_java_file ($write_filename, $option, "false", "boolean");
        }
        #add BUG ID:JBLWKK-33 chenshu 20140520  (end)
        #add JBLWKK-137 songqingming 20140609 (start)
        elsif ($option eq "RGK_MIN_MATCH_10") {
            &gen_java_file ($write_filename, $option, "false", "boolean");
        }
        #add JBLWKK-137 songqingming 20140609 (end)
        #add JWLWKK-1014 songqingming 20140617 (start)
        elsif ($option eq "RGK_CUSTOM_SIM_INDICATOR_SUPPORT") {
            &gen_java_file ($write_filename, $option, "false", "boolean");
        }
        #add JWLWKK-1014 songqingming 20140617 (end)
        #add JWLW-84 songqingming 20130916 (start)
        elsif ($option eq "RGK_POSITIVO_MATCH_NUMBER_SUPPORT") {
            &gen_java_file ($write_filename, $option, "false", "boolean");
        }
        #add JWLW-84 songqingming 20130916 (end)
        #add JLLB-726 songqingming 20140623 (start)
        elsif ($option eq "RGK_CUSTOM_BIND_SIM_CONTACTS_SUPPORT") {
            &gen_java_file ($write_filename, $option, "false", "boolean");
        }
        #add JLLB-726 songqingming 20140623 (end)
	#add JWLWKK-976 zhangzixiao 20140613 start
	elsif ($option eq "RGK_MUSIC_SUPPORT") {
            &gen_java_file ($write_filename, $option, "true", "boolean");
        }
	#add JWLWKK-976 zhangzixiao 20140613 end
		#begin add by zhouzhuobin for JLLB-696 20140619
		elsif ($option eq "RGK_SIM_COLOR_CUSTOM_SUPPORT") {
            &gen_java_file ($write_filename, $option, "false", "boolean");
        }
	#end add by zhouzhuobin for JLLB-696 20140619
	#add JLLB-411 zhangzixiao 20140623 start
	elsif ($option eq "SETTINGS_PREMIUM_ALWAYS_ALLOW") {
            &gen_java_file ($write_filename, $option, "false", "boolean");
        }
	#add JLLB-411 zhangzixiao 20140623 end
	
	#add JWLWKK-937 zhouzhuobin 20140623 start
	elsif ($option eq "RGK_ENABLE_SEKSELECTION_SUPPORT") {
            &gen_java_file ($write_filename, $option, "true", "boolean");
        }
	#add JWLWKK-937 zhouzhuobin 20140623 end
	#add chenshu 20140624 add for project control start
	elsif ($option eq "RGK_MOBIISTAR_SUPPORT") {
            &gen_java_file ($write_filename, $option, "false", "boolean");
        }
	#add chenshu 20140624 add for project control end	
        print "\"$option\" not match\n";
    }
}
print OUT_FILE "}\n";
close OUT_FILE;
sub gen_java_file {
	my ($filename, $option, $value, $type) = @_;
	print OUT_FILE "    /**\n     * check if $option is turned on or not\n     */\n";
	if ( $option eq "GEMINI") {
		print OUT_FILE "    public static final $type MTK_${option}_SUPPORT = $value;\n";
		print "public static final $type MTK_${option}_SUPPORT = $value\n";
	}
	else {
		print OUT_FILE "    public static final $type ${option} = $value;\n";
		print "public static final $type ${option} = $value\n";
	}
}
