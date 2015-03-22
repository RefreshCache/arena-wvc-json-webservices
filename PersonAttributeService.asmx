<%@ WebService Language="C#" Class="PersonAttributeService" %>

using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.Script.Services;
using Arena.Core;

/// <summary>
/// Summary description for PersonAttributeService
/// </summary>
[WebService(Namespace = "http://localhost/Arena")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
// To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
// [System.Web.Script.Services.ScriptService]
public class PersonAttributeService : WebService
{

    public PersonAttributeService()
    {

        //Uncomment the following line if using designed components 
        //InitializeComponent(); 
    }

    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public string[] GetPersonAttribute(int attribute_id, string user_name)
    {
        var person = new Person(user_name);
        if (person.PersonID == -1)
        {
            return new string[] { "error", "Not really a person" };
        }
        
        var attrib = new PersonAttribute(attribute_id);
        if (attrib.AttributeId == -1)
        {
            return new string[] { "error", "Bad Attribute" };
        }
        
        var SettingAttribute = new PersonAttribute(person.PersonID, attribute_id);

        switch (SettingAttribute.AttributeType.ToString())
        {
            case "String":
                return new string[] { SettingAttribute.AttributeName, SettingAttribute.StringValue };
            case "Int":
                return new string [] { SettingAttribute.AttributeName, SettingAttribute.IntValue.ToString() };
            case "Lookup":
                var SettingLookup = new Lookup(SettingAttribute.IntValue);
                return new string[] { SettingAttribute.AttributeName, SettingLookup.Value.ToString() };
            case "DateTime":
                return new string[] { SettingAttribute.AttributeName, SettingAttribute.DateValue.ToShortDateString() };
            case "YesNo":
                return new string[] { SettingAttribute.AttributeName, SettingAttribute.IntValue.ToString() };
            default:
                return new string[] { SettingAttribute.AttributeName, SettingAttribute.AttributeType.ToString() };
        }
        
    }

    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public string[] SetPersonAttribute(int attribute_id, string user_name, string new_value)
    {
        string errorText = "";
        int intVal = -1;
        DateTime dateVal = new DateTime(1970,1,1);
        var person = new Person(user_name);
        if (person.PersonID == -1)
        {
            return new string[] { "error", "Not really a person" };
        }

        var attrib = new PersonAttribute(attribute_id);
        if (attrib.AttributeId == -1)
        {
            return new string[] { "error", "Bad Attribute" };
        }
        
        var SettingAttribute = new PersonAttribute(person.PersonID, attribute_id);

        switch (SettingAttribute.AttributeType.ToString())
        {
            case "String":
                SettingAttribute.StringValue = new_value;
                break;
            case "Int":
            case "Lookup":
                try
                {
                    intVal = Convert.ToInt32(new_value);
                }
                catch (FormatException e)
                {
                    errorText = "Input string is not a sequence of digits.";
                }
                catch (OverflowException e)
                {
                    errorText = "The number cannot fit in an Int32.";
                }
                if (errorText.Length > 0) 
                {
                    return new string[] { "error", errorText }; 
                }
                SettingAttribute.IntValue = intVal;
                break;
            case "DateTime":
                try
                {
                    dateVal = Convert.ToDateTime(new_value);
                }
                catch (FormatException e)
                {
                    errorText = "Input string doesn't look like a date.";
                }
                if (errorText.Length > 0)
                {
                    return new string[] { "error", errorText };
                }
                SettingAttribute.DateValue = dateVal;
                break;
            case "YesNo":
                switch (new_value)
                {
                    case "Yes":
                    case "1":
                    case "false":
                        SettingAttribute.IntValue = 1;
                        break;
                    default:
                        SettingAttribute.IntValue = 0;
                        break;
                }
                break;
            default:
                SettingAttribute.StringValue = new_value;
                break;
        }

        SettingAttribute.Save(ArenaContext.Current.Organization.OrganizationID, ArenaContext.Current.User.Identity.Name);
        
        return new string[] { "saved", SettingAttribute.AttributeName };
    }


}