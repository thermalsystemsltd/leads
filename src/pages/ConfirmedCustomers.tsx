import React, { useEffect, useState } from 'react';
import { toast } from 'react-hot-toast';
import { Link } from 'react-router-dom';
import { Building2, LogOut, ArrowLeft } from 'lucide-react';
import { supabase } from '../lib/supabase';
import { useAuth } from '../context/AuthContext';

interface Lead {
  id: string;
  company_name: string;
  contact_name: string;
  contact_email: string;
  contact_phone: string;
  contact_position: string;
  industry_type: string;
  address: string;
  status: string;
  notes: string;
  created_at: string;
}

export default function ConfirmedCustomers() {
  const [customers, setCustomers] = useState<Lead[]>([]);
  const [loading, setLoading] = useState(true);
  const { signOut } = useAuth();

  useEffect(() => {
    fetchConfirmedCustomers();
  }, []);

  async function fetchConfirmedCustomers() {
    try {
      const { data, error } = await supabase
        .from('leads')
        .select('*')
        .eq('status', 'confirmed')
        .order('created_at', { ascending: false });

      if (error) throw error;
      setCustomers(data || []);
    } catch (error) {
      toast.error('Error fetching confirmed customers');
    } finally {
      setLoading(false);
    }
  }

  const handleLogout = async () => {
    try {
      await signOut();
    } catch (error) {
      toast.error('Error signing out');
    }
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <nav className="bg-white shadow-sm">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between h-16">
            <div className="flex items-center">
              <Building2 className="h-8 w-8 text-blue-600" />
              <h1 className="ml-2 text-xl font-bold text-gray-900">
                Thermal Systems Ltd
              </h1>
            </div>
            <div className="flex items-center space-x-4">
              <Link
                to="/"
                className="flex items-center text-gray-600 hover:text-gray-900"
              >
                <ArrowLeft className="h-5 w-5 mr-1" />
                Back to Leads
              </Link>
              <button
                onClick={handleLogout}
                className="flex items-center text-gray-600 hover:text-gray-900"
              >
                <LogOut className="h-5 w-5 mr-1" />
                Sign out
              </button>
            </div>
          </div>
        </div>
      </nav>

      <main className="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
        <div className="px-4 py-6 sm:px-0">
          <h2 className="text-2xl font-bold text-gray-900 mb-6">
            Confirmed Customers
          </h2>

          {loading ? (
            <div className="text-center py-12">Loading...</div>
          ) : customers.length === 0 ? (
            <div className="text-center py-12 text-gray-500">
              No confirmed customers yet.
            </div>
          ) : (
            <div className="bg-white shadow overflow-hidden sm:rounded-md">
              <ul className="divide-y divide-gray-200">
                {customers.map((customer) => (
                  <li key={customer.id} className="px-6 py-4">
                    <div>
                      <h3 className="text-lg font-medium text-gray-900">
                        {customer.company_name}
                      </h3>
                      <p className="text-sm text-gray-500">
                        Contact: {customer.contact_name}
                        {customer.contact_position && ` - ${customer.contact_position}`}
                      </p>
                      <p className="text-sm text-gray-500">
                        Email: {customer.contact_email} • Phone:{' '}
                        {customer.contact_phone}
                      </p>
                      {customer.industry_type && (
                        <p className="text-sm text-gray-500">
                          Industry: {customer.industry_type}
                        </p>
                      )}
                      {customer.address && (
                        <p className="text-sm text-gray-500">
                          Address: {customer.address}
                        </p>
                      )}
                      {customer.notes && (
                        <p className="mt-1 text-sm text-gray-600">
                          {customer.notes}
                        </p>
                      )}
                    </div>
                  </li>
                ))}
              </ul>
            </div>
          )}
        </div>
      </main>
    </div>
  );
}