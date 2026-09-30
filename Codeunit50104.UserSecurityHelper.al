/*
    Author: Niklas Dougherty <nd@abas.se>
    Date: 2026-09-30
    Description: Allow table read accces.
*/
codeunit 50104 "User Security Helper"
{
    Access = Internal;
    Permissions = tabledata "Access Control" = r;

    procedure CheckIfPremiumUser(): Boolean
    var
        AccessControl: Record "Access Control";
    begin
        AccessControl.SetRange("User Security ID", UserSecurityId());
        AccessControl.SetRange("Role ID", 'D365 BUS PREMIUM');

        exit(not AccessControl.IsEmpty());
    end;
}