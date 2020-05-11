#!/usr/bin/perl  -w
#use strict;

%arguments=
(
"AD"=>"T",		 #value mandatory, T==TRUE F==FALSE
"XL"=>"F",		 #value mandatory, F==FALSE T==TRUE
"vcf"=>"",		 #file	mandatory, provided at runtime
"disease"=>"",		 #name	optional
"similarD"=>"",          #file optional
"lgenes"=>"",            #file optional
"leQTL"=>"qfile",        #file   mandatory, but default value
"keywords"=>"kfile",	 #file	mandatory, but default value
"effects"=>"efile",	 #file	mandatory, but default value
"disease_clinvar"=>8, 	 #numeric mandadory, but default value
"score_AF"=>4, 		 #numeric mandatory, but default value
"score_functional"=>8,   #numeric mandatory, but default value
"score_NS"=>6,		 #numeric mandatory, but default value
"score_nIND"=>8,	 #numeric mandatory, but default value
"AF"=>0.0001,		 #numeric mandatory, but default value
"scoreeQTL"=>1,		 #numeric mandatory, but default value
"nind"=>5,		 #numeric  mandatory, but default value
"scoreG"=>2,		 #numeric  mandatory, but default value
"ifile"=>"inter_Hs.file", #file mandatory
"scoreI"=>1,		 #numeric mandatory
#####OUTPUT file#############################################
"ofile"=>"final_res.csv", #file #OUTPUT #tabulare
"ovcfile"=>"final_res.vcf"  #file #OUTOUT #vcf
);


@arguments=@ARGV;
for ($i=0;$i<=$#ARGV;$i+=2)
{
	$act=$ARGV[$i];
	$act=~s/-//g;
	$val=$ARGV[$i+1];
	if (exists $arguments{$act})
	{
		$arguments{$act}=$val;
	}else{
		warn("$act: unknown argument\n");
		@valid=keys %arguments;
		warn("Valid arguments are @valid\n");
		die("All those moments will be lost in time, like tears in rain.\n Time to die!\n");
	}
	#print "$act $val\n";
}

$ofile_name=$arguments{"ofile"};
open(O,">$ofile_name");
$ovcfile=$arguments{"ovcfile"};
open(OV,">$ovcfile");

$ifile=$arguments{"ifile"};
die ("input file $ifile not found!\n") unless -e $ifile;
open(IN,$ifile);
while(<IN>)
{
	($G1,$G2)=(split());
	push (@{$interact{$G1}},$G2);
}


$file=$arguments{"vcf"} ;
die ("input file $file not found!\n") unless -e $file;

$lgenes=$arguments{"lgenes"};
if (-e $lgenes)
{
	open(IN,$lgenes);
	while(<IN>)
	{
		chomp;
		$Lgenes{$_}=1;
	}
}


$kfile=$arguments{"keywords"};
die ("keyword file $kfile not found!\n") unless -e $kfile;
open(IN,$kfile);
while(<IN>)
{
	chomp;
	$specialKeys{$_}=1;	
}


$diseaseO=$arguments{"disease"} ? $arguments{"disease"} : "GinocchioValgoDellaLavandaiaZoppa";

$sfile=$arguments{"similarD"};
if (-e $sfile)
{
	open(IN,$sfile);
	while(<IN>)
	{
		chomp;
		push(@kw,$_)
	}
}

$efile=$arguments{"effects"};
die ("effect file $efile not found!\n") unless -e $efile;
open(IN,$efile);
while(<IN>)
{
        chomp;
        $effects{$_}=1;
}

$leQTLfile=$arguments{"leQTL"};
if (-e $leQTLfile)
{	
	open(IN,$leQTLfile);
        while(<IN>)
	{
		chomp();
		$Qlist{$_}=1;
	}
}

$disease_clinvar=$arguments{"disease_clinvar"};
$score_AF=$arguments{"score_AF"};
$score_functional=$arguments{"score_functional"};
$score_NS=$arguments{"score_NS"};
$score_nIND=$arguments{"score_nIND"};
$score_QTL=$arguments{"scoreeQTL"};
$scoreG=$arguments{"scoreG"};
$scoreI=$arguments{"scoreI"};
print O "CHR\tstart\tgene\tref\talt\tAC\t";
foreach $k (sort keys %specialKeys)
{
	print O "$k\t";
}
print O "VYNIL_score\n";

%damaged=();
open(IN,$file);

#print "$gene_score $disease_HGMD $disease_clinvar $score_functional $score_AF $score_NS $score_eQTL $score_nIND\n";
while(<IN>)
{
	if ($_=~/^#/)
	{
		print OV;
		next;
	}
	chomp();
	@val=(split(/\t/));
	$chr=$val[0];
	$start=$val[1];
	$pstart=$val[2];
	$b1=$val[3];
	$b2=$val[4];
	$qscore=$val[5];
	$pb2=$val[6];
	$gene="na";
	$annot=$val[7];
	$gt=$val[8];
	@samples=@val[9..$#val];
	$Nhom=0;
	$Nhet=0;
	foreach $s (@samples)
	{
		$sid=(split(/\:/,$s))[0];
		next if $sid eq ".";
		if ($sid=~/\|/)
		{
			($h1,$h2)=(split(/\|/,$sid))[0,1];
		}elsif($sid=~/\//){
			($h1,$h2)=(split(/\//,$sid))[0,1];
		}
		$Nhom++ if $h1==$h2;
		$Nhet++ if $h1!=$h2;	
	}
	$samples=(join("\t",@samples));
	@terms=(split(/\;/,$annot));
	$DIS=0;
	if ($_=~/;AC=(\d+);/)
	{
		$nind=$1;
	}
	if ($_=~/Gene.refGene=(\w+);/)
	{
		$gene=$1;
	}
	next if $nind==0;
	$gene=(split(/\,/,$gene))[0];
	$i=0;
	%keep=();
	$score=0;
	$score+=$scoreG if $Lgenes{$gene};
	if ($interact{$gene})
	{
		@interactors=@{$interact{$gene}};
		#print "$gene @interactors\n";
		foreach $interactor (@interactors)
		{
			print "$gene $interactor\n";
			$score+=$scoreI if $Lgenes{$interactor};
			print "adding $scoreI $score\n" if $Lgenes{$interactor};
		}
	}
	foreach $t (@terms)
	{
		($keep,$value)=(split(/\=/,$t))[0,1];
		$keep{$keep}=$value;
	}
	
	if ($keep{"CLNSIG"} ne "."){
		$scoreO=0;
        	$scoreC=0;
		$add=0;
		$add=$disease_clinvar  if ($keep{"CLNSIG"} eq "Pathogenic" || $keep{"CLNSIG"} eq "Pathogenic,_other,_risk_factor" || $keep{"CLNSIG"} eq "pathogenic" || $keep{"CLNSIG"} eq "Pathogenic/Likely_pathogenic" );
		$add=$disease_clinvar/2  if ($keep{"CLNSIG"} eq "Likely_pathogenic" || $keep{"CLNSIG"} eq "Conflicting_interpretations_of_pathogenicity" || $keep{"CLNSIG"} eq "likely-pathogenic");
		$add=-$disease_clinvar/2 if ($keep{"CLNSIG"} eq "Likely_benign"	||  $keep{"CLNSIG"} eq "Benign/Likely_benign");
		$add=-$disease_clinvar if ($keep{"CLNSIG"} eq "Benign");
		@diseases=split(/\|/,$keep{"CLNDN"});
                @databases=split(/\|/,$keep{"CLNDISDB"});
                for ($i=0;$i<=$#diseases;$i++)
                {
			$dis=lc $diseases[$i];
			$dat=$databases[$i];
			if ($dis=~ /$diseaseO/)
                       	{
                        	if ($dat=~/OMIM/)
                                {	
					$scoreO=$add;
                                }else{
					$scoreC=$add;
                                }
				last;
                        }else{
                        	foreach $kv (@kw)
                                {
					if ($dis=~/$kv/)
					{
						$DIS=1 if $add>0;
						if ($dat=~/OMIM/)
                                        	{
							$scoreO=$add;
                                        	}else{
							$scoreC=$add;
                                        	}
					}
                                 }
                        }
		}
		$score+=$scoreO+$scoreC;	
	}
	$esp=$keep{"esp6500siv2_ea"} eq "." ? 0 : $keep{"esp6500siv2_ea"};
	$g1000=$keep{"1000g2015aug_all"} eq "." ? 0 : $keep{"1000g2015aug_all"} ;
	$exac=$keep{"ExAC_NFE"} eq "." ? 0 : $keep{"ExAC_NFE"};
	$gnomad=$keep{"gnomAD_exome_NFE"} eq "." ? 0 : $keep{"gnomAD_exome_NFE"};
	@AF=($esp,$g1000,$exac,$gnomad);
	@AF=sort{$a<=>$b} @AF;
	$AF=$AF[-1];
	# Variante molto rara 0.0001 2 punti
	# Variante rara 0.004 1 punto
	if ($AF<=$arguments{"AF"}) #0,00002
	{
		$score+=$score_AF;
	}elsif($AF>$arguments{"AF"} && $AF<=$arguments{"AF"}*4){
		$score+=$score_AF/2;
	}elsif($AF>0.01){	#commonSNP
		$score-=$score_AF/2;
	}
	
	$effectO=(split(/\;/,$keep{"ExonicFunc.refGene"}))[0];
	if ($effects{$effectO})
	{
		 $damaged{$gene}{"D"}++;
		 $score+=$score_functional;
	}
	#print "Exon " . $keep{"ExonicFunc.refGene"}. " $score\n";
	if ($keep{"ExonicFunc.refGene"} eq "nonsynonymous_SNV"){
		
		if ($keep{"MetaSVM_pred"} eq "D" && $keep{"CADD_raw"}>=5)
		{
			$score+=$score_NS;
			$damaged{$gene}{"D"}++;
		}elsif($keep{"MetaSVM_pred"} eq "D" && $keep{"CADD_raw"}<5){
			$score+=$score_NS/2;
		}elsif($keep{"MetaSVM_pred"} ne "D" && $keep{"CADD_raw"}>=5){
                        $score+=$score_NS/2;
                }
	}
	#print "NS ". $keep{"ExonicFunc.refGene"} . " $score\n";
	$damaged{$gene}{"tot"}++;
	if ($keep{"Func.refGene"} eq "splicing"){
		$score+=$score_functional;
	}
	#print "SPL ". $keep{"Func.refGene"} . " $score\n";
	foreach $QTL  (keys %Qlist)
	{
		next unless $keep{$QTL};
		$score+=$score_QTL if ($keep{$QTL} ne ".");
	}
	if ($nind>=$arguments{"nind"} && $AF<=0.01)
	{
		$score+=$score_nIND;
	}elsif($nind>=$arguments{"nind"}/2 && $nind<$arguments{"nind"} && $AF<=0.01){
		$score+=$score_nIND/2;
	}
	chomp();
	#$scores{$score}++;
	chop($_);
	$outL="";
	foreach $k (sort keys %specialKeys)
	{
		 #die("$k\n") unless $keep{$k};
		$outL.="$keep{$k}\t";
	}
	$score=$score/2 if $arguments{"AD"} eq "T" && $Nhom==0;
	$score=$score/2 if $arguments{"XL"} eq "T" && $chr ne "chrX";
	print O "$chr\t$start\t$gene\t$b1\t$b2\t$nind\t$outL$score\n"; #if $score>=12 || $DIS==1;
	#        $chr=$val[0];

	print OV "$chr\t$start\t$pstart\t$b1\t$b2\t$qscore\t$pb2\t$annot;VINYL_score=$score\t$gt\t$samples\n";
}
