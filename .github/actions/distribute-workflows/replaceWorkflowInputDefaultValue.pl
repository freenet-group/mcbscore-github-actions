#!/usr/bin/env perl
# Ersetzt in Workflow YAML (von Stdin gelesen) den Default-Wert für den gegebenen Parameter-Namen
# mit dem gegebenen Wert.
# Einschränkungen:
# - Der Parameter muss schon einen Default-Wert haben.
# - Der Default-Wert muss einzeilig geschrieben sein (kein YAML-Umbruch mit "|" usw.)

$^W = 1;
use strict;
die "Usage: ... PARAM_NAME PARAM_VALUE" if scalar @ARGV != 2;
my $paramName = shift @ARGV;
my $paramValue = shift @ARGV;

$/ = undef; # "slurp mode" (<> liest bis EOF)
$_ = <>;
(my $result = $_) =~ s=(?<beforeValue>
	^(?<inputsIndent> \s+)inputs:.*\n

	# beliebig viele weiter als "inputs:" eingerückte Zeilen:
	(?: \g{inputsIndent}\s+.*\n)*

	# $paramName, weiter als "inputs:" eingerückt:
	(?<paramNameIndent> \g{inputsIndent}\s+) ${paramName}: .*\n

	# beliebig viele weiter als $paramName eingerückte Zeilen:
	(?: \g{paramNameIndent}\s+ .*\n )*
 
 	# Wert zu $paramName:
 	\g{paramNameIndent}\s+ default:\s*).*\n
=
	$+{beforeValue} . ${paramValue} . "\n"
=xme;
printf STDERR "Kein Parameter %s mit Default-Wert gefunden.\n", $paramName if $result eq $_;
print $result;
