/*
    Author: Niklas Dougherty <nd@abas.se>
    Date: 2026-09-29
    Description: Prevent sales staff from changing description on sales lines, with some exceptions.
*/

pageextension 50108 "Block Sales Line Desc" extends "Sales Order Subform"
{
    layout
    {
        modify(Description)
        {
            Editable = IsDescriptionEditable;
        }
    }

    trigger OnAfterGetRecord()
    begin
        EvaluateEditableCondition();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        EvaluateEditableCondition();
    end;

    var
        IsDescriptionEditable: Boolean;
        IsPremiumUser: Boolean;
        HasCheckedUserPlan: Boolean;

    local procedure EvaluateEditableCondition()
    var
        Item: Record Item;
    begin
        if (Rec.Type = Rec.Type::Item) and ((Rec."No." = '449') or (Rec."No." = '189')) then begin
            IsDescriptionEditable := true;
            exit;
        end;

        if Rec.Type = Rec.Type::" " then begin
            IsDescriptionEditable := true;
            exit;
        end;

        if Rec.Type = Rec.Type::Item then begin
            if Rec."No." <> '' then begin
                if Item.Get(Rec."No.") then begin
                    if Item.Type <> Item.Type::Inventory then begin
                        IsDescriptionEditable := true;
                        exit;
                    end;
                end;
            end;
        end;

        if not HasCheckedUserPlan then begin
            IsPremiumUser := CheckIfPremiumUser();
            HasCheckedUserPlan := true;
        end;

        if (Rec.Type = Rec.Type::Item) and (Rec."No." <> '') then begin
            if Item.Get(Rec."No.") then begin
                if Item.Type = Item.Type::Inventory then begin
                    IsDescriptionEditable := IsPremiumUser;
                    exit;
                end;
            end;
        end;

        IsDescriptionEditable := false;
    end;

    local procedure CheckIfPremiumUser(): Boolean
    var
        AccessControl: Record "Access Control";
    begin
        AccessControl.SetRange("User Security ID", UserSecurityId());
        AccessControl.SetRange("Role ID", 'D365 BUS PREMIUM');
        // AccessControl.SetFilter("Company Name", '%1|%2', '', CompanyName());

        exit(not AccessControl.IsEmpty());
    end;
}