#!/usr/bin/env perl
use Cwd;
use File::Copy;
use DirHandle;
my $dir;
my $target_dir;

for ($a=0; $a<@ARGV; $a++)
  {
    my $v=$ARGV[$a];
    print "-----[$v]---";
    if ($v eq "-dir")
      {
	$dir="$ARGV[++$a]/";
      }
    elsif ($v eq "-target_dir")
      {
	$target_dir=$ARGV[++$a];
      }
    elsif ($v eq "-action")##ibooks to synchronyze itune lib
      {
	$action="-$ARGV[++$a]";
      }
    
    elsif ($v eq "-replace")
      {
	$action=$v;
	$string_in=$ARGV[++$a];
	$string_out=$ARGV[++$a];
      }
    elsif ($v eq "-addbefore")
      {
	$action=$v;
	$addbefore=$ARGV[++$a];
      }
    elsif ($v eq "-addafter")
      {
	$action=$v;
	$addafter=$ARGV[++$a];
      }
    elsif ($v eq "-remove_number")
      {
	$action=$v;
      }
    elsif ($v eq "-renumber")
      {
	$action=$v;
	$number_range=$ARGV[++$a];
      }
    elsif ($v eq "-mp3")
      {
	$action=$v;
      }
    elsif ($v eq "-mp3")
      {
	$action=$v;
      }
    elsif ($v eq "-title")
      {
	$title=$ARGV[++$a];
      }
    else
      {
	print "[$v] is an unknown argument"; die;
      }
  }



if (!$dir){$dir=getcwd;}
if (!$target_dir){$target_dir=getcwd;}

opendir (DIR,$dir);
@file1=readdir (DIR);
closedir (DIR);
if       ($action eq "-rcbx2pdf")
  {
    rec_image2pdf ($dir);
  }
elsif    ($action eq "-list_itune")
  {
    my $d1=getcwd;
    chdir ("..");
    rec_list_itune($d1);
    chdir ($d1);
    
  }
elsif    ($action eq "-clean_itune")
  {
    my $d1=getcwd;
    chdir ("..");
    rec_clean_itune($d1);
    chdir ($d1);
    
  }
elsif    ($action eq "-itune")
  {
    my $d1=getcwd;
    chdir ("..");
    rec_clean_mp3($d1);
    chdir ($d1);
  }
elsif    ($action eq "-ibooks")## synchronyze itune lib: rename_book.pl -action ibooks
  {
    my $d1=getcwd;
    my $dh1=new DirHandle;
    chdir ("..");
    opendir ($dh1, $d1);
    my @l1=readdir($dh1);
    closedir($dh1);
    
    foreach my $d2 (@l1)
      {
	
	if ($d2 =~/Novels\./)
	  {
	    my $dh2=new DirHandle;
	    print "\n---Process $d2\n";
	    opendir ($dh2, "$d1/$d2");
	    my @l2=readdir($dh2);
	    close ($dh2);
	    
	    foreach my $d3 (@l2)
	      {
		$hlist{$d3}="$d1/$d2/$d3";
	      }
	  }
      }
    chdir ("$d1");
    
    if (!-e "./itune.new") {mkdir ("./itune.new");}
    if (!-e "./itune.full"){mkdir ("./itune.full");}
    

#1 Remove from itune.full files removed from the sources    
    my  $i=new DirHandle;
    opendir ($i, "./itune.full");
    my @itune_list=readdir($i);
    closedir($i);
    foreach my $b (@itune_list)
      {
	if ($b ne "." && $b ne ".." && !$hlist{$b})
	  {
	    print "Remove $b from itune.full\n";
	    unlink ("./itune.full/$b");
	    $removedbooks++;
	  }
	else
	  {
	    $totbooks++;
	  }
      }
#2 Add new Books to itune lib   
    opendir ($dh1, "itune.full");
    @l1=readdir ($dh1);
    closedir    ($dh1);
    
    
    foreach my $b (keys (%hlist))
      {

	my $old="./itune.full/$b";
	my $new=$hlist{$b};
	
	
	if (!-e $old)
	  {
	    print "NEW iBOOK: $new\n";
	    system ("cp \"$new\" ./itune.new");
	    $newbooks++;
	    $totbooks++;
	  }
      }
    if ($newbooks>0)
      {
	system ("mv ./itune.full ./itune.old");
	system ("mv ./itune.new ./itune.full");
	print "\nFound $newbooks new books\n";
	print "\nInput to itune: go to itune and import from: $d1/itune.full\nPress Return when finished\n";
	$next=<STDIN>;
	system "mv ./itune.full ./itune.new";
	system "mv ./itune.old  ./itune.full";
	my $dh1=new DirHandle;
	opendir ($dh1,"./itune.new");
	my @l1=readdir ($dh1);
	closedir ($dh1);
	
	foreach my $b (@l1)
	  {
	    if ($b ne "." && $b ne "..")
	      {
		print "ADD $b to iTune library\n";
		system ( "mv ./itune.new/\"$b\" ./itune.full");
	      }
	  }
	
	
      }
    else
      {
	print "Did not find any new book to update\n";
      }

    print "\nSummary:\n\t$totbooks books in itune.full\n\tRemoved: $removedbooks\n\tAdded: $newbooks\n";
    system "rmdir ./itune.new";

    die;
  }


    
elsif    ($action eq "-cbx2pdf")
  {
    
    foreach $f (@file1)
      {
	my $print =1;
	my $of;

	if ($f=~/\.pdf/){next;}
	elsif ($f=~/\.rar/ ||$f=~/\.cbr/ )
	  {
	    mkdir "tmp";chdir "tmp";
	    system "cp ../\"$f\" file.rar"; 
	    system "unrar e file.rar"; unlink "file.rar";
	  }
	elsif ($f=~/\.zip/ ||$f=~/\.cbz/) 
	  {
	    mkdir "tmp";chdir "tmp";
	    system "cp ../\"$f\" file.zip";
	    system "unzip file.zip"; unlink "file.zip";
	  }
	else{next;}
		
	if   ($f=~/(.*)\.rar/){$of="$1.pdf";}
	elsif($f=~/(.*)\.zip/){$of="$1.pdf";} 
	elsif($f=~/(.*)\.cbz/){$of="$1.pdf";} 
	elsif($f=~/(.*)\.cbr/){$of="$1.pdf";} 
	

	if ( $print==1)
	  {
	    &dump_cfg();
	    system "jpg2pdf *.jpg";
	    system "mv jpegs.pdf ../\"$of\"";
	  }
	chdir "..";
	system ("rm -r tmp");
      }
  }
elsif       ($action eq "-zip")
  {
    foreach $f (@file1)
      {
	print $f;
	system ("zip \"$f\"");
      }
  }

elsif       ($action eq "-alexandriz")
  {
    foreach $f (@file1)
      {
	print $f;
	if ($f=~/\.rar/)
	  {
	    system ("cp \"$f\" tmp");
	    print "---- unrar $f\n";
	    system "unrar e -y tmp";
	    system ("cp tmp/*.epub .");
	    system ("rm -r tmp");
	  }
      }
  }

elsif       ($action eq "-unrar")
      {
	foreach $f (@file1)
	  {
	    if ($f=~/\.rar/)
	      {
		system ("cp \"$f\" tmp");
		print "---- unrar $f\n";
		system "unrar e -y tmp";
	      }
	  }
      }

elsif($action eq "-mp3")
      {
	print "\nmp3";
	foreach my $f (@file1)
	  {
	    my $from=$f;
	    $from=~/(.*)\.([^.]*)/;
	    my $t=$1;
	    my $e=$2;
	    my $i1="intermediate.$e";
	    my $i2="intermediate.mp3";
	    my $to="$t\.mp3";
	    if ($e eq "flac" || $e eq "m4a")
	      {
		&my_rename ($from,$i1);
		system ("ffmpeg -i $i1 -acodec libmp3lame -ab 320 $i2");
		&my_rename ($i2,$to);
	      }
	  }
      }
elsif($action eq "-remove_number")
      {
	print "\nremove_number";
	foreach my $f (@file1)
	  {
	    if (!$title || $f=~/$title/)
	      {
		
		my $from=$to=$f;
		
		
		if ($from=~/(\d+)(.*)/)
		  {
		    my $num=int ($1);
		    $to=~s/$num//;
		    
		    print("mv  \"$from\"  \"$to\"\n");
		    &my_rename ($from,$to);
		  }
		
	      }
	  }
      }
elsif($action eq "-renumber")
      {
	print "\nrenumber";
	foreach my $f (@file1)
	  {
	    if (!$title || $f=~/$title/)
	      {
		
		my $from=$f;
		
		
		if ($from=~/(\d+)(.*)/)
		  {
		    my $x=int ($1);
		    my $t=$2;
		    
		    my $num;
		    
		    
		    if ($x<10){$num="000".$x;}
		    elsif ($x<100){$num="00".$x;}
		    elsif ($x<1000){$num="0".$x;}
		    else {$num=$x;}
		    
		    my $to="$num$t";
		    print("mv  \"$from\"  \"$to\"\n");
		    &my_rename ($from,$to);
		  }
		
	      }
	  }
      }
elsif       ($action eq "-addbefore" || $action eq "-addafter")
      {
	print "\n";
	foreach my $f (@file1)
	  {
	    if (!$title || $f=~/$title/)
	      {
		my $from=$f;
		my $to=($action eq "-addbefore")?"$addbefore$f":"$f$addafter";
		
		if ($from ne $to && $from ne "." && $from ne "..")
		  {
		    print("mv  \"$from\"  \"$to\"\n");
		    &my_rename ($from,$to);
		  }
	      }
	  }
      }
elsif    ($action eq "-meta4epub")
  {
    foreach my $f (@file1)
      {
	if (!$title || $f=~/$title/)
	  {
	    epub2author("set",$f);
	  }
      }
  }
elsif    ($action eq "-epub2meta")
  {
    foreach my $f (@file1)
      {
	if (!$title || $f=~/$title/)
	  {
	    epub2author("read",$f);
	  }
      }
  }
elsif    ($action eq "-meta4pdf")
  {
    #depnds on exiftool
    foreach my $f (@file1)
      {
	if (!$title || $f=~/$title/)
	  {
	    setmeta4pdf($f)
	  }
      }
  }

elsif    ($action eq "-pn2np")#prenom nom - titre TO Nom.Prenom_-_Titre
  {
    foreach my $f (@file1)
      {
	if (!$title || $f=~/$title/)
	  {
	    my $to="";
	    if ($f=~/_-_/){;}
	    elsif (($f=~/(\S*) (\S*)\s+-\s+(.*)/))
	      {
		my $su=$1;
		my $na=$2;
		my $ti=$3;
		$su=~s/_/\./g;
		$na=~s/_/\./g;
		
		$to="$na.$su\_-_$ti";
	      }
	    elsif (($f=~/(\S*)\s+-\s+(.*)/))
	      {
		my $na=$1;
		my $ti=$2;
		
		$na= ucfirst($na);
		$ti= ucfirst($ti);

		$na=~s/_/\./g;
		$to="$na\_-_$ti";
	      }
	    
	    else
	      {
		$to=~s/\.\./\./g;
		print "\n***** CANNOT rename;\n$f\n";
		die;
	      }
	    if ($to ne ""){&my_rename($f, $to);}
	    
	  }
      }
    print "\nFinished Everything\n";
  }

elsif    ($action eq "-tnp2npt")#prenom nom - titre TO Nom.Prenom_-_Titre
  {
    foreach my $f (@file1)
      {
	if (!$title || $f=~/$title/)
	  {
	    my $to="";
	    if (($f=~/(.*) - (.*)\.epub/))
		{
		  my $ti=$1;
		  my $fn=$2;
		  $fn=~s/[\.,_-]/ /;
		  $fn=~s/\s+/ /g;
		  $to="$fn\_-_$ti";
		  print "\n$to.epub";
		  &my_rename ($f,$to);
		}
	  }
	else
	  {
	    print "******* $f\n";
	  }
      }
  }
elsif    ($action eq "-dir2file")
  {
    foreach my $sd (@file1)
      {
	if ($sd ne "." && $sd ne "..")
	  {
	    opendir (SUBDIR,$sd);
	    my @file2=readdir (SUBDIR);
	    closedir (SUBDIR);
	    if (@{[$sd =~ /\./g]}>1)
	      {
		print "\nERROR:$sd\n";
		die;
	      }
	    
	    foreach my $from (@file2)
	      {
		if ($from ne "." && $from ne ".." && $from ne ".DS_Store")
		  {
		    if ($sd=~/_Anth/){;}
		    elsif (($from=~/(.*)_-_(.*)/))
		      {
			my $title=$2;
			my $to=$sd."_-_".$title;
			if ($from ne $to)
			  {
			    print "\nFR: $from\nTO: $to\n";
			    rename ("$sd/$from","$sd/$to");
			    
			  }
		      }
		    elsif (($from=~/(.*) - (.*)(\..*)/))
		      {
			my $first=$1;
			my $second=$2;
			my $ext=$3;
			print "\n$from\n";
			print "author: 1/2/0\n";
			my $order=<STDIN>;
			my $to;
			if ($order eq "1\n")
			  {
			    my $title=$2;
			    $to=$sd."_-_".$title.$ext;
			  }
			elsif ($order eq "2\n") 
			  {
			    my $title=$1;
			    $to=$sd."_-_".$title.$ext;
			  }
			else
			  {
			    print "*** Could not parse: $sd/$from\n";
			    die;
			  }
			if ($from ne $to)
			  {
			    print "\nFR: $from\nTO: $to\n";
			    rename ("$sd/$from","$sd/$to");
			  }
		      }
		    else
		      {
			print "*** Could not parse: $sd/$from\n";
			die;
		      }
		  }
	      }
	  }
      }
    print "\nFinished Everything!!!"
  }
elsif    ($action eq "-rename_dir")#will try to rename the dir interactively
  {
    foreach my $sd (@file1)
      {
	rename_author_dir ($sd);
      }
    die;
  }

elsif    ($action eq "-file2dir")
  {
    my $nd="$dir.Classified";
    mkdir "$nd";
    print "mkdir $nd\n";
    foreach my $f (@file1)
      {
	if (($f=~/(.*)_-_(.*)/))
	  {
	    my $a=$1;
	    if (!-d "$nd/$a")
	      {
		mkdir ("$nd/$a");
		print "\tmkdir $nd/$a\n";
	      }
	    if (!-e "$nd/$a/$f")
	      {
		copy ($f, "$nd/$a/$f");
		print "\t#copy ($f, $nd/$a/$f)\n";
	      }
	  }
	else
	  {
	    print "Could not parse: $f\n";
	  }
      }
  }
elsif    ($action eq "-replace")
  {
    print "\n";
    foreach my $f (@file1)
      {
	if ((!$title ||$f=~/$title/) && $f=~/$string_in/)
	  {
	    
	    my $from=$f;
	    my $to=$f;
	    $to=~s/$string_in/$string_out/;
	    if ($from ne $to && $from ne "." && $from ne "..")
	      {
		print "---- mv $from --> $to\n";
		&my_rename ($from,$to);
	      }
	  }
      }
  }

elsif ($action eq "-sync")##for the sony reader
  {
    
    $s="$dir";
    $d=$target_dir;
    if ( -d $s)
      {
	opendir (DIR,$s);
	@source=readdir (DIR);
	closedir (DIR);
      }
    else
      {
	print "$s is not a valid source\n";
	die;
      }
    if ( -d $d)
      {
	opendir (DIR,$d);
	@dest=readdir (DIR);
	closedir (DIR);
      }
    else
      {
	print "$d is not a valid destination\n";
	die;
      }
    
    foreach $f (@source){if (!($f=~/^\..*/) && !($f=~/Sony/)){$hsource{$f}=$f;}}
    foreach $f (@dest)  {if (!($f=~/^\..*/) && !($f=~/Sony/)){$hdest{$f}=$f;}}
    $ns=$#source+1;
    $nd=$#dest+1;
    foreach $f (keys(%hsource))
      {
	$nns++;
	if ( $hdest{$f})
	  {
	    print "-----SKIP: $f ($nns/$ns)\n";
	  }
	else
	  {
	    print "-----ADD: $f ($nns/$ns)\n";
	    copy ("$s/$f", "$d/$f");
	  }
      }

    foreach $f (keys(%hdest))
      {
	$nnd++;
	if ( $hsource{$f})
	  {
	    print "-----KEEP: $f ($nnd/$nd)\n";;
	  }
	else
	  {
	    print "-----PURGE: $f ($nnd/$nd)\n";
	    unlink "$d/$f";
	  }
      }
    
    die;
  }

elsif ($action eq "-upper")
  {
    foreach $f (@file1)
      {
	$new=$f; 
	#upper_case first letter
	$new=~/(.)(.*)/;
	$first=$1;
	$second=$2;
	$first=uc($first);
	$new=$first.$second;
	
	if ($f ne $new)
	  {
	    print "mv '$f' $new\n";
	    rename $f,$new;
	  }
      }
  }
elsif ($action eq "-misc")
  {
    foreach $f (@file1)
      {
	$new=$f;
	
	if ( ($f =~/\s/ || $f=~/-/ || $f=~/,/) && -d $ARVG[2])
	  {
	    rename $f,"$ARGV[2]/$f";
	  }
      }
  }
elsif ($action eq "-clean")
  {
    foreach $f (@file1)
      {
	$new=$f;
	
	$new=~s/_-_/XCEDRICX/g;
	
	$new=~s/^La\ /La\./;
	$new=~s/^Le\ /Le\./;
	$new=~s/^Les\ /Les\./;
	$new=~s/^De\ /De\./;
	$new=~s/^Du\ /Du\./;
	$new=~s/^Des\ /Des\./;
	
	
	
	$new=~s/\&/et/g;
	$new=~s/\ /_/g;
	$new=~s/\-/_/g;
	$new=~s/\,/\./g;
	$new=~s/\(/_/g;
	$new=~s/\)/_/g;
	$new=~s/\]/_/g;
	$new=~s/\[/_/g;
	$new=~s/__/_/g;
	$new=~s/__/_/g;
	$new=~s/\'/_/g;
	
	#get read of long tags
	$new=~s/\.ebook\.AlexandriZ//g;
	$new=~s/\.Ebook\.AlexandriZ//g;
	$new=~s/\.OCR//g;
	
	
	if (($new=~/(.*)\\(.*)/)){$new=$2};#truncate duplicated long names
	
	$new=~s/XCEDRICX/_-_/g;
	if (!($new=~/_-_/)){$new=~s/_/_-_/;}#separate autor/title, sony style
	
	#upper_case first letter
	$new=~/(.)(.*)/;
	$first=$1;
	$second=$2;
	$first=uc($first);
	$new=$first.$second;
	
	if ($f ne $new)
	  {
	    print "mv '$f' $new\n";
	    my_rename ($f,$new);
	  }
      }
  }
elsif ($action eq "-dup1")
  {
    
    foreach $f1 (@file1)
      {
	
	$f1=~/(.*)_-_(.*)\.([^.]*)/;
	$auteur=$1;
	$titre=$2;
	$ext=$3;
	$hash{$titre}{$ext}=$f1;
	$hash{$titre}{auteur}=$auteur;
	$hash{$titre}{titre}=$titre;
	
	print "$titre\n";
      }

    foreach $k (keys (%hash))
      {
	if ($hash{$k}{pdf} && $hash{$k}{epub})
	  {
	    $ac="mv $hash{$k}{pdf} $target_dir";
	    print "--- $ac\n";
	    system ("$ac");
	  }
      }
  }
else
  {
    print "\nUnknown Action\n";
  }

sub my_rename
  {
    my $f=shift;
    my $s=shift;

    rename ($f, $s);
  }
sub dump_cfg
  {
    open F, ">jpg2pdf.cfg";
    print F "  paper : image\n";
    close F;

# You can use these variables
#
# author : 
# creator :
# keywords :
# subject : 
# title :
# 
# If the value of author, creator, keywords, subject is not
# known there are omited
# If the value of title is null, the file name is introduced
#
# default paper is letter
  paper : image
#
# Scaling image factor
# scale : 1.0
#
# You can use also A3 (or a3), A4 (or a3), A5 (or a4), tabloid, ledger,
# legal, statement, executive, image
# The image paper will configure every PDF page with the image format

# Background design file
# bgdesign : bgdesign.txt
# Foreground design file
# fgdesign : fgdesign.txt

# imagex (default 0) is the distance from the left page border of the bottom-left
# point of the image
# imagey (default 0) is the distance from the bottom page border of the bottom-left
# point of the image
# remember don't set imagex and imagey with a number bigger than the paper dimension

# imagex : 50
# imagey : 50

# These is the list of all the transition effect (the default is replace)
# transition:replace
# transition : split!H!I!
# transition : split!H!O!
# transition : split!V!I!
# transition : split!V!O!
# transition : blinds!H!
# transition : blinds!V!
# transition : box!I!
# transition : box!O!
# transition : wipe!0!
# transition : wipe!90!
# transition : wipe!180!
# transition : wipe!270!
# transition : dissolve
# transition : glitter!0!
# transition : glitter!270!
# transition : glitter!315!

# The 2 supported page modes are FullScreen and UseThumbs
# (thumbnail page images should be displayed automatically)
# pagemode : FullScreen

# The only supported page layouts are OneColumn, TwoColumnsLeft, TwoColumnRight
# pagelayout : OneColumn

# Encoding : you can select one from WinAnsiEncoding, MacRomanEncoding, MacExpertEncoding
# typeencoding : default


}

sub rec_image2pdf
  {
    my $f=shift;
    my @file2;
    
    if ( -d $f)
      {
	print "DIR: $f\n";
	my $d=new DirHandle;
	opendir ($d,$f);
	my @fl=readdir ($d);
	chdir $d;
	
	foreach my $f (@fl)
	  {
	    if ( $f eq "." || $f eq ".."){;}
	    elsif (-d $f){rec_image2pdf ($f);}
	    else
	      {
		print "\tProcess FILE: $f\n";
		image2pdf ($f);
	      }
	  }
	chdir "..";
      }
  }

sub image2pdf
  {
    my $f=shift;
    my $of;
    my $insize=-s $f;
    

    if   ($f=~/(.*)\.rar/){$of="$1.pdf";}
    elsif($f=~/(.*)\.zip/){$of="$1.pdf";} 
    elsif($f=~/(.*)\.cbz/){$of="$1.pdf";} 
    elsif($f=~/(.*)\.cbr/){$of="$1.pdf";} 

    if (-e "tmp"){system "rm -rf tmp";}
    if (-e $of){$outsize= -s $of; $ratio=$outsize/$insize;}
    print "RATIO=$ratio";
    
    
    if ( !-e $f) {return;}
    elsif (-e $of && $ratio>0.5){return;}
    
    elsif ($f=~/\.pdf/){return;}
    elsif ($f=~/\.rar/ ||$f=~/\.cbr/ )
      {
	mkdir "tmp";chdir "tmp";
	system "cp ../\"$f\" file.rar"; 
	system "unrar e file.rar"; unlink "file.rar";
      }
    elsif ($f=~/\.zip/ ||$f=~/\.cbz/) 
      {
	mkdir "tmp";chdir "tmp";
	system "cp ../\"$f\" file.zip";
	system "unzip file.zip"; unlink "file.zip";
      }
    else{return;}
    
    
    
    &dump_cfg();
    system "cp */*.jpg .";
    system "cp */*/*.jpg .";

    mkdir "pngs";
    system "cp *.png pngs";
    system "cp */*.png pngs";
    system "cp */*/*.png pngs";
    chdir "pngs";
    mkdir "jpgs";
    system "sips -s format jpeg *.* --out jpgs";
    system "mv jpgs/* ..";
    chdir "..";
    
    
    system "jpg2pdf  *.jpg";
    system "mv jpegs.pdf ../\"$of\"";
    chdir "..";
    system ("chmod -R u+w tmp");
    system ("rm -rf tmp");
  }

sub rec_list_itune
  {
    my $d1=shift;
    my $depth=shift;
    my $dh1=new DirHandle;
    opendir ($dh1, $d1);
    my @l1=readdir($dh1);
    closedir($dh1);
    $depth++;
    foreach my $d2 (@l1)
      {
	my $ren=0;
	my $in=$d2;
	my $out;
	
	$in=lc($d2);
	
	if ($d2 eq "." || $d2 eq "..")
	  {
	    ;
	  }
	elsif (-d "$d1/$d2")
	  {
	    rec_list_itune ("$d1/$d2", $depth);
	  }
	elsif ( $in=~/\.flac/)
	  {
	    $nflac++;
	    print "SPECIAL FORMAT::$d1/$d2\n";
	    
	  }
	elsif ($in=~/\.ape/)
	  {
	    $nape++;
	    print "SPECIAL FORMAT::$d1/$in\n";
	    
	  }
	 elsif ($in =~/\.wav/ )
	  {
	    $nwav++;
	    print "SPECIAL FORMAT::$d1/$d2\n";
	  }
	elsif ($in =~/ogg/ )
	  {
	    $nogg++;
	    print "SPECIAL FORMAT::$d1/$d2\n";
	  }
	elsif ( $in=~/mp3/)
	  {
	    $nmp3++;
	  }
	
      }
    if ($depth==1)
      {print "\nmp3: $nmp3";
       print "\nflac: $nflac";
       print "\nape: $nape";
       print "\nogg: $nogg";
       print "\nwav: $nwav";
     }
    return;
  }
sub rec_clean_itune
  {
    my $d1=shift;
    my $dh1=new DirHandle;
    opendir ($dh1, $d1);
    my @l1=readdir($dh1);
    closedir($dh1);
    
    foreach my $d2 (@l1)
      {
	my $ren=0;
	my $in=$d2;
	my $out;
	
	$in=~s/MP3/mp3/g;
	$in=~s/Mp3/mp3/g;
	$in=~s/JPG/jpg/g;
	$in=~s/Jpg/jpg/g;
	
	
	if ($d2 eq "." || $d2 eq "..")
	  {
	    ;
	  }
	elsif (-d "$d1/$d2")
	  {
	    rec_clean_itune ("$d1/$d2");
	  }
	elsif ( $in =~/\.CUE/ ||$in =~/\.m3u/ ||$in =~/\.nfo/|| $in =~/\.ipa/||$in =~/\.sfv/||$in =~/\.cue/||$in =~/\.log/ ||$in =~/\.exe/ ||$in =~/\.url/ || $in =~/\.html/ ||$in =~/\.ini/||$in =~/\.par2/||$in =~/\.PAR2/||$in =~/\.db/||$in =~/\.nzb/||$in =~/\.htm/||$in =~/\.mpc/||$in =~/\.kar/||$in =~/\.aif/ )
	  {
	    print "REMOVE::$d1/$in";
	    system "rm -f \"$d1/$in\"";
	  }
	
	elsif ( !($in =~/mp3/) &&!($in =~/jpg/) && !($in =~/flac/)&& !($in =~/ogg/)&& !($in =~/m4a/)&& !($in =~/mp4/)&& !($in =~/bmp/)&& !($in =~/ape/) &&!($in =~/gif/) &&!($in =~/\.wma/) &&!($in =~/\.BMP/)&&!($in =~/\.wav/) && !($in =~/\.txt/) && !($in =~/\.TXT/) && !($in =~/\.mpg/)&& !($in =~/\.jpeg/)&& !($in =~/DS_Store/)&&!($in =~/pdf/)&&!($in =~/png/)&&!($in =~/rtf/)&&!($in =~/\.doc/))
	  {
	    print "KEEP::$d1/$in\n";
	  }

      }
    return ;
  }
sub rec_clean_mp3 
  {
    my $d1=shift;
    my $dh1=new DirHandle;
    opendir ($dh1, $d1);
    my @l1=readdir($dh1);
    closedir($dh1);
    
    foreach my $d2 (@l1)
      {
	my $ren=0;
	my $in=$d2;
	my $out;
	
	$in=~s/MP3/mp3/g;
	$in=~s/Mp3/mp3/g;
	$in=~s/JPG/jpg/g;
	
	
	if ($d2 eq "." || $d2 eq "..")
	  {
	    ;
	  }
	elsif (-d "$d1/$d2")
	  {
	    rec_clean_mp3 ("$d1/$d2");
	  }
	elsif ( $in =~/\.mp3\.mp3/)
	  {
	    $ren=1;
	    $out="$in";
	    $out=~s/mp3\.mp3/mp3/;
	  }
	elsif ( $in =~/mp3\.mp3/)
	  {
	    $ren=1;
	    $out="$in";
	    $out=~s/mp3\.mp3/\.mp3/;
	  }
	elsif ( $in =~/mp3.*mp3/)
	  {
	    $ren=1;
	    $out=$in;
	    $out=~s/mp3//g;
	    $out="$out\mp3";
	    
	    print "$out\n";
	  }
	elsif ( $d2 =~/MP3/)
	  {
	    $ren=1;
	    $out=$in;
	  }
	
	    
	if ($ren)
	  {
	    print "--$d1/$d2\n";
	    print "--$d1/$out\n\n";
	    
	    rename("$d1/$d2", "$d1/$out");
	  }
      }
    return ;
  }

sub setmeta4epub
  {
    my $f=shift;
    if (!($f=~/\.epub/)){return;}
    elsif (($f=~/(.*)_-_(.*)\.epub/))
      {
	my $author=$1;
	my $title=$2;
	my $language;
	$title=~s/_/\ /g;
      }
    if (($f=~/(.*)_-_(.*)\.pdf/)){};
  }
sub setmeta4pdf
  {
    my $f=shift;
    if (!($f=~/\.pdf/) || ($f=~/\.pdf_original/)){return;}
    my ($author,$title,$language)=fname2list($f);
    print "exiftool $f -Title=\"$title\" -Author=\"$author\" -language=\"$language\"\n";
    system "exiftool \"$f\" -Title=\"$title\" -Author=$author -language=$language";
  }

sub fname2list
  {
    my $f=shift;
    my $author;
    my $title;
    my $language;
    
    if (($f=~/(.*)_-_(.*)\.pdf$/) || ($f=~/(.*)_-_(.*)\.epub$/))
      {
	$author=$1;
	$title=$2;
	$title=~s/_/\ /g;
	($title,$language)=file2language($title);
      }
    else
      {
	print "Cannot Parse $f\n";
	die;
      }
    return ($author,$title,$language);
  }
sub file2language
  {
    my $t=shift;
    my @language=("english","french","spanish");
    foreach my $l (@language)
      {
	if (($t=~/\.$l/))
	  {
 	    $t=~s/\.$l//;
	    return $t,$l;
	  }
      }
    return $t,"french";
  }
sub epub2author
  {
    my $action=shift;
    my $f=shift;
    my ($p,$l);
    my $mf="iTunesMetadata.plist";
    my @list;
    my @meta;
    my @author_list;
    
    
    if ($f eq "." || $f eq ".." || !($f=~/\.epub$/)){return;}
    my ($author,$title,$language)=fname2list($f);
    $author=~s/\./\,\ /;
    @author_list=(@author_list, "Filename: $author");
   
    if (-d "tmp4rename_book"){"rm -r tmp4rename_book";}
    mkdir "tmp4rename_book";
    copy ("$f", "./tmp4rename_book/$f");
    chdir "./tmp4rename_book";
    system "unzip -q \"$f\" ";
    
    @meta=dir2list_ext (".", "opf",@meta);
    @meta=dir2list_ext (".", "plist", @meta);
    foreach my $mf (@meta)
      {
	if ($action eq "set")
	  {
	    SetEpubMeta($mf,$author,$title,$language);
	    system ("zip -qu \"$f\" \"$mf\"");
	  }
	elsif ($action eq "read")
	  {
	    @author_list=(@author_list,EpubMeta2author($mf));
	  }
      }
    copy ("$f", "..");
    chdir ("..");
    system "rm -r tmp4rename_book";

    foreach my $n (@author_list)
      {print "$n\n";}
    return @author_list;
  }

sub SetEpubMeta
  {
    my $f=shift;
    my $aut=shift;
    my $ti=shift;
    my $lang=shift;
    my ($l,$p);
    
    open IN, "$f";
    open OUT,">$f.new";
    while (<IN>)
      {
	$l=$_;
	if ($f=~/\.opf$/ && ($l=~/\<dc:creator.*\>(.*)\<\/dc:creator\>/))
	  {
	    my $iaut=$1;
	    $l=~s/$iaut/$aut/;
	  }
      	elsif ($f=~/iTunesMetadata.plist/ && $p =~/artistName/ ||$p =~/sort-artist/ )
	  {
	    $l="\t<string>$aut</string>\n";
	  }
	print OUT "$l";
	$p=$l;
      }
    close (IN);
    close (OUT);
    move ("$f.new", "$f");
    return;
  }
sub EpubMeta2author
  {
    my $f=shift;
    my $aut=shift;
    my $ti=shift;
    my $lang=shift;
    my ($l,$p);
    my @list;
    open IN, "$f";
    while (<IN>)
      {
	$l=$_;
	if ($f=~/\.opf$/ && ($l=~/\<dc:creator.*\>(.*)\<\/dc:creator\>/))
	  {
	    @list=(@list, "opf: $1");
	  }
	elsif ($f=~/iTunesMetadata.plist/ && $p =~/artistName/)
	  {
	    $l=~/\<string\>(.*)\<\/string\>/;
	    @list=(@list, "iTune_artistName: $1");
	  }
	elsif ($f=~/iTunesMetadata.plist/ && $p =~/sort-artist/ && $l=~/\<string\>/)
	  {
	    $l=~/\<string\>(.*)\<\/string\>/;
	    @list=(@list, "iTune_sort-artist: $1");
	  }
	$p=$l;
      }
    close (IN);
    return @list;
  }

sub dir2list_ext
  {
    my $sdir=shift;
    my $ext=shift;
    my @list=@_;
    
    my $d1=getcwd;
    my $dh1=new DirHandle;
    opendir ($dh1, $d1);
    my @l1=readdir($dh1);
    closedir($dh1);

    foreach my $d2 (@l1)
      {
	if ($d2 eq "." || $d2 eq "..")
	  {;}
	elsif (-d $d2)
	  {
	    system "chmod u+rwx ./$d2";
	    chdir ("./$d2") || die;
	    @list=dir2list_ext ("$sdir\/$d2",$ext, @list);
	    chdir ("..");
	  }
	elsif ($d2=~/\.$ext$/)
	  {
	    @list=(@list,"$sdir/$d2");
	  }
      }
    return @list;
  }


sub rename_author_dir
  {
    my $dir=shift;
    my $dh1=new DirHandle;
    
    if ($dir eq "." || $dir eq ".." || $dir eq ".DS_Store"){return;}
    print "First $dir\n";
    opendir ($dh1, $dir);
    my @l1=readdir($dh1);
    closedir($dh1);
    chdir ($dir);
    
    foreach my $b (@l1)
      {
	if ($b eq "." || $b eq ".."){next;}
	my @list=epub2author ("read", $b);
	foreach my $name (@list)
	  {
	    print "$name\n";die;
	    print "accept, invert, next, quit\n";
	    my $action=<STDIN>;
	  }
	
	die;
      }
    chdir ("..");
    return;
  }
       
	
