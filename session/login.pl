#!C:\PERL\bin\perl.exe
  
# login.pl
use CGI;
use CGI::Carp qw/fatalsToBrowser warningsToBrowser/;
use CGI::Session ( '-ip_match' );

$q = new CGI;

$usr = $q->param('usr');
$pwd = $q->param('pwd');

if($usr ne ''){
    # process the form
    if($usr eq "demo" and $pwd eq "demo"){
        $session = new CGI::Session();
        print $session->header(-location=>'index.pl');
    }else{
        print $q->header(-type=>"text/html",-location=>"login.pl");
    }
}elsif($q->param('action') eq 'logout'){
    $session = CGI::Session->load() or die CGI::Session->errstr;
    $session->delete();
    print $session->header(-location=>'login.pl');
}else{
    print $q->header;
    print q|
    <form method="post">
        Username: <input type="text" name="usr">
        Password: <input type="password" name="pwd">
        <input type="submit">
    </form>
    |;
}