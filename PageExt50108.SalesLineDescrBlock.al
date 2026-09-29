pageextension 50108 "Block Sales Line Desc" extends "Sales Order Subform"
{
    layout
    {
        modify(Description)
        {
            Editable = IsDescriptionEditable;
            StyleExpr = DescriptionStyle;
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
        DescriptionStyle: Text;

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
        UsersInPlans: Query "Users in Plans";
    begin
        UsersInPlans.SetRange(User_Security_ID, UserSecurityId());
        UsersInPlans.Open();
        while UsersInPlans.Read() do begin
            if StrPos(LowerCase(UsersInPlans.Plan_Name), 'premium') > 0 then begin
                UsersInPlans.Close();
                exit(true);
            end;
        end;
        UsersInPlans.Close();
        exit(false);
    end;
}