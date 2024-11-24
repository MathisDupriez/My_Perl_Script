#!/usr/bin/perl
use strict;
use warnings;

my $service_name = "auto_update.service";
my $service_path = "/etc/systemd/system/$service_name";

# Désactiver le service
system("systemctl disable $service_name 2>/dev/null");
system("systemctl stop $service_name 2>/dev/null");

# Supprimer le fichier de service
if (-f $service_path) {
    unlink($service_path) or die "Impossible de supprimer le fichier $service_path : $!\n";
    system("systemctl daemon-reload");
    print "Le service de mise à jour automatique a été désactivé et supprimé.\n";
} else {
    print "Le service de mise à jour automatique n'existe pas.\n";
}
