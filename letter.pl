#!/usr/bin/perl -w

use v5.10;
use Curses;

initscr();
raw();
noecho();

my @words;
open(my $f, "<", "words.txt");

while(<$f>) {
  chomp;
  push(@words, $_);
}

close($f);

my ($maxy, $maxx) = (0, 0);
getmaxyx($stdscr, $maxy, $maxx);

my ($top, $left) = (2, $maxx / 3);

sub start {
  $state{"word"} = $words[rand $#words];
  $state{"guess"} = $state{"word"} =~ s/./_/gr;
  $state{"letters"} = "abcdefghijklmnopqrstuvwxyz";
  $state{"mistakes"} = 0;
  $state{"isActive"} = 1;

  addstr(8, 4, $state{"word"} =~ s/./_ /gr);

  addstr(2, $maxx / 2, "Lives @{[ 6 - $state{\"mistakes\"} ]}");
  addstr(6, $maxx / 2, "<Shift-N>   Refresh Game");
  addstr(8, $maxx / 2, "<Shift-Q>   Quit Game");

  addstr($top, $left, "|---|");
  addstr($top + 1, $left, "|");
  addstr($top + 1, $left + 4, "|");
  addstr($top + 2, $left + 4, "|");
  addstr($top + 3, $left + 4, "|");
  addstr($top + 4, $left + 4, "|");
  addstr($top + 5, $left + 4, "|");
  addstr($top + 6, $left + 2, "__|__");

  addstr($top + 10, 4, uc($state{"letters"}) =~ s/(.)/$1  /gr);

  curs_set(0);
}

sub draw {
  addstr(2, $maxx / 2, "Lives @{[ 6 - $state{\"mistakes\"} ]}") if ($state{"mistakes"} < 7);

  addstr(8, 4, $state{"guess"} =~ s/(.)/$1 /gr);

  addstr($top + 10, 4, (uc($state{"letters"}) =~ s/(.)/$1  /gr) =~ s/\./ /gr);

  addstr($top + 2, $left, "O") if ($state{"mistakes"} >= 1);
  addstr($top + 3, $left, "|") if ($state{"mistakes"} >= 2);
  addstr($top + 3, $left - 1, "/") if ($state{"mistakes"} >= 3);
  addstr($top + 3, $left + 1, "\\") if ($state{"mistakes"} >= 4);
  addstr($top + 4, $left, "|") if ($state{"mistakes"} >= 5);
  addstr($top + 5, $left - 1, "/") if ($state{"mistakes"} >= 6);
  addstr($top + 5, $left + 1, "\\") if ($state{"mistakes"} >= 7);

  curs_set(0);
}

sub process {
  my $c = shift @_;

  if ($state{"letters"} !~ /$c/g) {
    return 1;
  }

  $state{"letters"} =~ s/$c/./;

  if ($state{"word"} !~ /$c/) {
    return 0;
  }

  while ($state{"word"} =~ /($c)/g) {
    substr($state{"guess"}, pos($state{"word"}) - 1, 1, $c);
  }

  return 1;
}

start();
while (1) {
  my $c = getch();

  if ($c eq 'N') {
    erase();
    start();
  }

  if ($c eq 'Q') {
    last;
  }

  unless ($state{"isActive"}) {
    next;
  }

  unless (process($c)) {
    $state{"mistakes"}++ ;
  }

  draw();

  if ($state{"guess"} !~ /_/) {
    addstr(4, 4, "Yay! You've won :)");
    $state{"isActive"} = 0;
  }

  if ($state{"mistakes"} > 6) {
    addstr(4, 4, "Shoot! You've lost :(");

    addstr(8, 4, $state{"word"} =~ s/(.)/$1 /gr);
    $state{"isActive"} = 0;
  }
}

END { endwin(); }
